#!/bin/bash
# Local load test: mocked S3 (moto) + the real cloud_model app under gunicorn + Locust.
# Usage: ./run.sh [users] [seconds]      (defaults: 100 users, 40 s)
# Needs: pip install -r requirements.txt   (run from cloud_model/loadtest)
set -e
cd "$(dirname "$0")"
USERS=${1:-100}; SECS=${2:-40}
WORK=$(mktemp -d); trap 'kill $(jobs -p) 2>/dev/null; rm -rf "$WORK"' EXIT

export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://127.0.0.1:5001 MODEL_DIR="$WORK/models" TF_CPP_MIN_LOG_LEVEL=3

moto_server -p 5001 >"$WORK/moto.log" 2>&1 &
sleep 3
python -c 'import boto3; boto3.client("s3").create_bucket(Bucket="ml-retrain-bucket")'

(cd .. && PORT=8080 gunicorn app:app -k gthread -w 4 --threads 8 -b 127.0.0.1:8080 -t 300 >"$WORK/app.log" 2>&1) &
until curl -sf localhost:8080/health >/dev/null; do sleep 1; done

python gen_data.py 1000 "$WORK/train.csv"
for i in 0 1 2 3 4; do curl -s -o /dev/null -F file=@"$WORK/train.csv" localhost:8080/add_user/u$i; done
for i in 0 1 2 3 4; do until curl -s localhost:8080/status/u$i | grep -q '"ok":true.*"running":false'; do sleep 2; done; done
echo "5 users trained; running Locust ($USERS users, ${SECS}s)"

locust -f locustfile.py --headless -H http://localhost:8080 -u "$USERS" -r 50 -t "${SECS}s" PredictUser
