import sys, os, json, time, fcntl, shutil, tempfile, io
from concurrent.futures import ThreadPoolExecutor
import boto3, pandas as pd, numpy as np, joblib
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.callbacks import EarlyStopping

BUCKET = os.environ.get("MODEL_BUCKET", "ml-retrain-bucket")
LOCAL_MODEL_DIR = os.environ.get("MODEL_DIR", "/home/ubuntu/user_models")
STATE_DIR = os.path.join(LOCAL_MODEL_DIR, ".state")
s3 = boto3.client("s3")

CONTINUOUS = ["tap_duration", "swipe_velocity", "touch_pressure", "tap_interval_avg",
              "accel_variance", "gyro_variance", "battery_level", "brightness_level",
              "screen_on_time", "time_of_day_sin", "time_of_day_cos", "wifi_id_hash",
              "gps_latitude", "gps_longitude", "device_orientation", "touch_area",
              "touch_event_count", "app_usage_time"]
BINARY = ["accel_variance_missing", "gyro_variance_missing", "charging_state",
          "wifi_info_missing", "gps_location_missing",
          "day_of_week_mon", "day_of_week_tue", "day_of_week_wed",
          "day_of_week_thu", "day_of_week_fri", "day_of_week_sat", "day_of_week_sun"]


def notify(text):
    # Telegram token removed from source: read it from the environment instead.
    token, chat = os.environ.get("TELEGRAM_TOKEN"), os.environ.get("TELEGRAM_CHAT_ID")
    if not token or not chat:
        return
    try:
        import requests
        requests.post(f"https://api.telegram.org/bot{token}/sendMessage",
                      data={"chat_id": chat, "text": text}, timeout=5)
    except Exception as e:
        print(f"telegram failed: {e}", file=sys.stderr)


def load_json_data(user_id):
    prefix = f'users/{user_id}/data/incoming/'
    keys = [o["Key"] for page in s3.get_paginator("list_objects_v2").paginate(Bucket=BUCKET, Prefix=prefix)
            for o in page.get("Contents", []) if o["Key"].endswith(".json")]
    with ThreadPoolExecutor(16) as ex:
        rows = list(ex.map(lambda k: json.loads(s3.get_object(Bucket=BUCKET, Key=k)['Body'].read()), keys))
    return pd.DataFrame(rows)


def train(user_id):
    csv = s3.get_object(Bucket=BUCKET, Key=f'users/{user_id}/data/initial_training.csv')
    df = pd.concat([pd.read_csv(csv['Body']), load_json_data(user_id)], ignore_index=True)
    df[CONTINUOUS] = df[CONTINUOUS].fillna(0)
    df[BINARY] = df[BINARY].fillna(0)

    scaler = StandardScaler()
    X = np.hstack([scaler.fit_transform(df[CONTINUOUS]), df[BINARY].values])

    inp = Input(shape=(X.shape[1],))
    x = Dense(32, activation='relu')(inp)
    x = Dense(16, activation='relu')(x)
    x = Dense(32, activation='relu')(x)
    model = Model(inp, Dense(X.shape[1], activation='linear')(x))
    model.compile(optimizer='adam', loss='mse')
    model.fit(X, X, epochs=100, batch_size=64, validation_split=0.2,
              callbacks=[EarlyStopping(patience=10, restore_best_weights=True)], verbose=0)
    err = np.mean(np.square(X - model.predict(X, verbose=0)), axis=1)
    return model, scaler, float(np.percentile(err, 95)), len(df)


def main(user_id):
    os.makedirs(STATE_DIR, exist_ok=True)
    if os.environ.get("LOCK_FD"):                  # lock inherited from app.py
        lock = int(os.environ["LOCK_FD"])
    else:                                          # run by hand
        lock = os.open(os.path.join(STATE_DIR, f"{user_id}.lock"), os.O_CREAT | os.O_RDWR)
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print("retrain already running", file=sys.stderr); sys.exit(2)

    status_path = os.path.join(STATE_DIR, f"{user_id}.status.json")
    started = time.time()
    tmp = tempfile.mkdtemp(prefix=f"{user_id}_train_", dir=STATE_DIR)    # private scratch dir
    try:
        model, scaler, threshold, n_rows = train(user_id)
        model.save(f"{tmp}/model.h5")
        joblib.dump(scaler, f"{tmp}/scaler.pkl")
        joblib.dump(threshold, f"{tmp}/threshold.pkl")
        joblib.dump({"continuous_features": CONTINUOUS, "binary_features": BINARY}, f"{tmp}/feature_info.pkl")
        prefix = f'users/{user_id}/model/'
        # threshold.pkl last: serving uses its ETag as the "model version" marker
        for local, remote in (("model.h5", "autoencoder_model.h5"), ("scaler.pkl", "scaler.pkl"),
                              ("feature_info.pkl", "feature_info.pkl"), ("threshold.pkl", "threshold.pkl")):
            s3.upload_file(f"{tmp}/{local}", BUCKET, prefix + remote)
        result = {"ok": True, "rows": n_rows, "seconds": round(time.time() - started, 1), "finished": time.time()}
        notify(f"Model retrained for user {user_id}")
    except Exception as e:
        result = {"ok": False, "error": str(e), "finished": time.time()}
        notify(f"Retrain failed for {user_id}")
        print(e, file=sys.stderr); raise
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
        json.dump(result, open(status_path, "w"))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python retrain.py <user_id>"); sys.exit(1)
    main(sys.argv[1])
