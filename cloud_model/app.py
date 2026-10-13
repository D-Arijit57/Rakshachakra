from flask import Flask, request, jsonify
import boto3, joblib, json, numpy as np, tensorflow as tf
import os, re, sys, time, tempfile, shutil, threading, subprocess, fcntl
from werkzeug.utils import secure_filename

app = Flask(__name__)
BUCKET = os.environ.get("MODEL_BUCKET", "ml-retrain-bucket")
s3 = boto3.client("s3")
LOCAL_MODEL_DIR = os.environ.get("MODEL_DIR", "/home/ubuntu/user_models")
STATE_DIR = os.path.join(LOCAL_MODEL_DIR, ".state")
HERE = os.path.dirname(os.path.abspath(__file__))
REVALIDATE_SECS = 10          # how often a cached model is checked against S3
os.makedirs(STATE_DIR, exist_ok=True)

USER_RE = re.compile(r"^[A-Za-z0-9_-]{1,64}$")
ARTIFACTS = ["autoencoder_model.h5", "scaler.pkl", "threshold.pkl", "feature_info.pkl"]

_cache, _cache_lock, _user_locks = {}, threading.Lock(), {}


def valid_user(user_id):
    return bool(USER_RE.match(user_id))


def _model_version(user_id):
    # threshold.pkl is uploaded last by retrain.py, so its ETag marks a complete model set
    return s3.head_object(Bucket=BUCKET, Key=f"users/{user_id}/model/threshold.pkl")["ETag"]


def _load_from_s3(user_id):
    tmp = tempfile.mkdtemp(prefix=f"{user_id}_", dir=STATE_DIR)   # private dir: no clashes with retrain
    try:
        for name in ARTIFACTS:
            s3.download_file(BUCKET, f"users/{user_id}/model/{name}", os.path.join(tmp, name))
        model = tf.keras.models.load_model(os.path.join(tmp, ARTIFACTS[0]), compile=False)
        return (model, joblib.load(os.path.join(tmp, "scaler.pkl")),
                joblib.load(os.path.join(tmp, "threshold.pkl")),
                joblib.load(os.path.join(tmp, "feature_info.pkl")))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def get_artifacts(user_id):
    now = time.time()
    entry = _cache.get(user_id)
    if entry and now - entry["checked"] < REVALIDATE_SECS:
        return entry["art"]
    with _cache_lock:
        ulock = _user_locks.setdefault(user_id, threading.Lock())
    with ulock:                                   # one loader per user, others wait then hit the cache
        entry = _cache.get(user_id)
        if entry and time.time() - entry["checked"] < REVALIDATE_SECS:
            return entry["art"]
        version = _model_version(user_id)
        if entry and entry["version"] == version:
            entry["checked"] = time.time()
            return entry["art"]
        art = _load_from_s3(user_id)
        _cache[user_id] = {"art": art, "version": version, "checked": time.time()}
        return art


def _start_retrain(user_id):
    """Spawn retrain.py in the background. Returns False if one is already running for this user."""
    lock_path = os.path.join(STATE_DIR, f"{user_id}.lock")
    fd = os.open(lock_path, os.O_CREAT | os.O_RDWR)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        os.close(fd)
        return False
    # hand the already-locked fd to the child: the lock is never released in between
    try:
        subprocess.Popen([sys.executable, os.path.join(HERE, "retrain.py"), user_id],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True,
                         pass_fds=[fd], env={**os.environ, "LOCK_FD": str(fd)})
    finally:
        os.close(fd)
    return True


@app.route('/predict/<user_id>', methods=['POST'])
def predict(user_id):
    if not valid_user(user_id):
        return jsonify({"error": "invalid user_id"}), 400
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify({"error": "JSON object body required"}), 400
    try:
        model, scaler, threshold, info = get_artifacts(user_id)
    except Exception as e:
        app.logger.exception("model load failed")
        return jsonify({"error": "model unavailable"}), 404
    try:
        cont = [float(data[f]) for f in info['continuous_features']]
        binr = [float(data[f]) for f in info['binary_features']]
    except (KeyError, TypeError, ValueError) as e:
        return jsonify({"error": f"missing or non-numeric feature: {e}"}), 400

    x = np.hstack([scaler.transform([cont]), [binr]]).astype("float32")
    recon = model(x, training=False).numpy()
    error = float(np.mean(np.square(x - recon), axis=1)[0])

    s3.put_object(Bucket=BUCKET, Key=f'users/{user_id}/data/incoming/session_{time.time_ns()}.json',
                  Body=json.dumps(data))
    return jsonify({"risk_score": round(error, 4), "anomaly": int(error > threshold)})


@app.route('/retrain/<user_id>', methods=['POST'])
def retrain_user(user_id):
    if not valid_user(user_id):
        return jsonify({"error": "invalid user_id"}), 400
    if not _start_retrain(user_id):
        return jsonify({"status": "already_running"}), 409
    return jsonify({"status": "started"}), 202


@app.route('/add_user/<user_id>', methods=['POST'])
def add_user(user_id):
    if not valid_user(user_id):
        return jsonify({"error": "invalid user_id"}), 400
    f = request.files.get('file')
    if f is None or not secure_filename(f.filename or "").endswith('.csv'):
        return jsonify({"error": "CSV file required under 'file' field"}), 400
    with tempfile.NamedTemporaryFile(suffix=".csv", dir=STATE_DIR, delete=False) as tmp:
        f.save(tmp.name)
    try:
        s3.upload_file(tmp.name, BUCKET, f'users/{user_id}/data/initial_training.csv')
    finally:
        os.unlink(tmp.name)
    if not _start_retrain(user_id):
        return jsonify({"status": "already_running"}), 409
    return jsonify({"status": "started", "poll": f"/status/{user_id}"}), 202


@app.route('/status/<user_id>', methods=['GET'])
def status(user_id):
    if not valid_user(user_id):
        return jsonify({"error": "invalid user_id"}), 400
    fd = os.open(os.path.join(STATE_DIR, f"{user_id}.lock"), os.O_CREAT | os.O_RDWR)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        running = False
    except BlockingIOError:
        running = True
    finally:
        os.close(fd)
    p = os.path.join(STATE_DIR, f"{user_id}.status.json")
    last = json.load(open(p)) if os.path.exists(p) else None
    return jsonify({"running": running, "last": last})


@app.route('/health', methods=['GET'])
def health():
    return "Server up", 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 80)))
