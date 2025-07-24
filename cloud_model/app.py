from flask import Flask, request, jsonify
import boto3
import joblib
import json
import numpy as np
import tensorflow as tf
import os
import time
import subprocess
from werkzeug.utils import secure_filename

# ---------- CONFIG ----------
app = Flask(__name__)
BUCKET = 'ml-retrain-bucket'
s3 = boto3.client('s3')
LOCAL_MODEL_DIR = "/home/ubuntu/user_models"
os.makedirs(LOCAL_MODEL_DIR, exist_ok=True)


# ---------- HELPERS ----------
def download_model_artifacts(user_id):
    prefix = f'users/{user_id}/model/'
    user_dir = os.path.join(LOCAL_MODEL_DIR, user_id)
    os.makedirs(user_dir, exist_ok=True)

    model_path = os.path.join(user_dir, 'model.h5')
    scaler_path = os.path.join(user_dir, 'scaler.pkl')
    threshold_path = os.path.join(user_dir, 'threshold.pkl')
    info_path = os.path.join(user_dir, 'feature_info.pkl')

    s3.download_file(BUCKET, prefix + 'autoencoder_model.h5', model_path)
    s3.download_file(BUCKET, prefix + 'scaler.pkl', scaler_path)
    s3.download_file(BUCKET, prefix + 'threshold.pkl', threshold_path)
    s3.download_file(BUCKET, prefix + 'feature_info.pkl', info_path)

    model = tf.keras.models.load_model(model_path, compile=False)
    scaler = joblib.load(scaler_path)
    threshold = joblib.load(threshold_path)
    feature_info = joblib.load(info_path)

    return model, scaler, threshold, feature_info


# ---------- ROUTES ----------
@app.route('/predict/<user_id>', methods=['POST'])
def predict(user_id):
    try:
        model, scaler, threshold, feature_info = download_model_artifacts(user_id)
        cont_feats = feature_info['continuous_features']
        bin_feats = feature_info['binary_features']

        data = request.get_json()
        cont = [data[f] for f in cont_feats]
        binr = [data[f] for f in bin_feats]
        scaled = scaler.transform([cont])
        full_input = np.hstack([scaled, [binr]])
        recon = model.predict(full_input)
        error = np.mean(np.square(full_input - recon), axis=1)[0]
        is_anomaly = int(error > threshold)

        # Save data to S3 for future retraining
        timestamp = int(time.time())
        s3.put_object(
            Bucket=BUCKET,
            Key=f'users/{user_id}/data/incoming/session_{timestamp}.json',
            Body=json.dumps(data)
        )

        return jsonify({
            "risk_score": round(error, 4),
            "anomaly": is_anomaly
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/retrain/<user_id>', methods=['POST'])
def retrain_user(user_id):
    try:
        result = subprocess.run(['python3', 'retrain.py', user_id], capture_output=True, text=True)
        if result.returncode != 0:
            return jsonify({
                "status": "error",
                "stderr": result.stderr
            }), 500

        return jsonify({
            "status": "success",
            "message": "Model retrained and reloaded."
        })

    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


@app.route('/add_user/<user_id>', methods=['POST'])
def add_user(user_id):
    try:
        if 'file' not in request.files:
            return jsonify({"error": "CSV file required under 'file' field"}), 400

        file = request.files['file']
        filename = secure_filename(file.filename)
        if not filename.endswith('.csv'):
            return jsonify({"error": "Only CSV accepted"}), 400

        # Save locally and upload to S3
        tmp_path = f'/tmp/{filename}'
        file.save(tmp_path)

        # Create necessary folders (S3 "folders" are just key prefixes)
        s3.put_object(Bucket=BUCKET, Key=f'users/{user_id}/model/')
        s3.put_object(Bucket=BUCKET, Key=f'users/{user_id}/data/incoming/')

        # Upload initial training data
        s3.upload_file(tmp_path, BUCKET, f'users/{user_id}/data/initial_training.csv')

        # Retrain immediately
        result = subprocess.run(['python3', 'retrain.py', user_id], capture_output=True, text=True)
        if result.returncode != 0:
            return jsonify({
                "status": "partial_success",
                "message": "User created but retraining failed.",
                "stderr": result.stderr
            }), 500

        return jsonify({
            "status": "success",
            "message": f"User {user_id} created and model retrained."
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/health', methods=['GET'])
def health():
    return "Server up", 200


# ---------- ENTRY ----------
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)