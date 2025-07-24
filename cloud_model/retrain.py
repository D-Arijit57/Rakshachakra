import sys, os, boto3, json, pandas as pd, numpy as np, joblib, requests
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.callbacks import EarlyStopping

BUCKET = "ml-retrain-bucket"
s3 = boto3.client("s3")
TELEGRAM_TOKEN = "7654919250:AAFMKxw-RQVxPXehJtlBuDIc-dnNEhBr88o"
TELEGRAM_CHAT_ID = "5376135729"

def send_telegram(text):
    try:
        requests.post(f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage",
                      data={"chat_id": TELEGRAM_CHAT_ID, "text": text})
    except: pass

def load_json_data(user_id):
    response = s3.list_objects_v2(Bucket=BUCKET, Prefix=f'users/{user_id}/data/incoming/')
    rows = []
    for obj in response.get("Contents", []):
        key = obj["Key"]
        if key.endswith(".json"):
            content = s3.get_object(Bucket=BUCKET, Key=key)['Body'].read()
            rows.append(json.loads(content))
    return pd.DataFrame(rows)

def main(user_id):
    continuous = [
        "tap_duration", "swipe_velocity", "touch_pressure", "tap_interval_avg",
        "accel_variance", "gyro_variance", "battery_level", "brightness_level",
        "screen_on_time", "time_of_day_sin", "time_of_day_cos", "wifi_id_hash",
        "gps_latitude", "gps_longitude", "device_orientation", "touch_area",
        "touch_event_count", "app_usage_time"
    ]
    binary = [
        "accel_variance_missing", "gyro_variance_missing", "charging_state",
        "wifi_info_missing", "gps_location_missing",
        "day_of_week_mon", "day_of_week_tue", "day_of_week_wed",
        "day_of_week_thu", "day_of_week_fri", "day_of_week_sat", "day_of_week_sun"
    ]

    try:
        csv_obj = s3.get_object(Bucket=BUCKET, Key=f'users/{user_id}/data/initial_training.csv')
        df_csv = pd.read_csv(csv_obj['Body'])
        df_json = load_json_data(user_id)
        df = pd.concat([df_csv, df_json], ignore_index=True)

        df[continuous] = df[continuous].fillna(0)
        df[binary] = df[binary].fillna(0)

        scaler = StandardScaler()
        X_cont = scaler.fit_transform(df[continuous])
        X = np.hstack([X_cont, df[binary].values])

        inp = Input(shape=(X.shape[1],))
        x = Dense(32, activation='relu')(inp)
        x = Dense(16, activation='relu')(x)
        x = Dense(32, activation='relu')(x)
        out = Dense(X.shape[1], activation='linear')(x)

        model = Model(inputs=inp, outputs=out)
        model.compile(optimizer='adam', loss='mse')
        model.fit(X, X, epochs=100, batch_size=64, validation_split=0.2,
                  callbacks=[EarlyStopping(patience=10, restore_best_weights=True)],
                  verbose=0)

        preds = model.predict(X)
        recon_error = np.mean(np.square(X - preds), axis=1)
        threshold = np.percentile(recon_error, 95)

        local_path = f"/home/ubuntu/user_models/{user_id}"
        os.makedirs(local_path, exist_ok=True)
        model.save(f"{local_path}/model.h5")
        joblib.dump(scaler, f"{local_path}/scaler.pkl")
        joblib.dump(threshold, f"{local_path}/threshold.pkl")
        joblib.dump({"continuous_features": continuous, "binary_features": binary},
                    f"{local_path}/feature_info.pkl")

        prefix = f'users/{user_id}/model/'
        s3.upload_file(f"{local_path}/model.h5", BUCKET, prefix + "autoencoder_model.h5")
        s3.upload_file(f"{local_path}/scaler.pkl", BUCKET, prefix + "scaler.pkl")
        s3.upload_file(f"{local_path}/threshold.pkl", BUCKET, prefix + "threshold.pkl")
        s3.upload_file(f"{local_path}/feature_info.pkl", BUCKET, prefix + "feature_info.pkl")

        send_telegram(f"✅ Model retrained for user {user_id}")
    except Exception as e:
        send_telegram(f"❌ Retrain failed for {user_id}: {str(e)}")
        raise

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python retrain.py <user_id>")
        sys.exit(1)
    main(sys.argv[1])