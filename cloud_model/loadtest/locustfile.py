import random
from locust import HttpUser, task, constant_throughput
from gen_data import rows
USERS = [f"u{i}" for i in range(5)]
NORMAL = [{k: float(v) for k, v in r.items()} for r in rows(200, 7).to_dict("records")]
ANOM = [{k: float(v) for k, v in r.items()} for r in rows(50, 8, True).to_dict("records")]

class PredictUser(HttpUser):
    weight = 20
    """Phone sending one behavioural session per second; 10% anomalous."""
    wait_time = constant_throughput(1)
    @task
    def predict(self):
        p = random.choice(ANOM if random.random() < 0.1 else NORMAL)
        with self.client.post(f"/predict/{random.choice(USERS)}", json=p, catch_response=True, name="/predict") as r:
            if r.status_code != 200: r.failure(f"{r.status_code} {r.text[:80]}")

class RetrainUser(HttpUser):
    weight = 3
    """Hammers /retrain on ONE user to expose blocking + write races."""
    wait_time = constant_throughput(0.2)
    @task
    def retrain(self):
        with self.client.post("/retrain/u0", catch_response=True, name="/retrain", timeout=300) as r:
            if r.status_code not in (202, 409): r.failure(f"{r.status_code} {r.text[:80]}")
