# Backend Load Test & Audit — `cloud_model`

Scope: the Flask service in `cloud_model/` that scores behavioural sessions for each user and stores
per-user artifacts in S3. This document covers the service as a **backend system** (concurrency,
I/O, state, failure modes, security). The model internals are out of scope.

## 1. System under test

| Component | Responsibility |
|---|---|
| `POST /predict/<user_id>` | Load that user's artifacts, score one session, store the raw session in S3 |
| `POST /add_user/<user_id>` | Upload initial CSV to S3, trigger first training run |
| `POST /retrain/<user_id>` | Re-run training on initial CSV + all stored sessions |
| `GET /health`, `GET /status/<user_id>` | Liveness; training status (added in this change) |
| S3 (`ml-retrain-bucket`) | Source of truth: `users/<id>/data/...` and `users/<id>/model/...` |

## 2. Test method

- **Environment:** MacBook Air (8 cores), Python 3.11. Load generator and server on the same machine,
  so absolute numbers are conservative for the server but ignore real network latency.
- **S3:** mocked with `moto` (local HTTP server). Real S3 adds 10–50 ms per call, which makes the
  original design (4 downloads per request) look *worse* than measured here.
- **Data:** synthetic. 5 users, 1,000 training rows each.
- **Tool:** Locust. Each simulated client sends one `/predict` per second (10% anomalous input).
  A second scenario hammers `/retrain` on one user while predict traffic runs.
- **Reproduce:** `cd cloud_model/loadtest && pip install -r requirements.txt && ./run.sh 100 40`

Baseline = original `app.py`/`retrain.py` (commit `8836530`), patched only to change file paths and
disable Telegram. After = the code in this branch.

## 3. Findings and fixes

### 3.1 Throughput bottleneck: state rebuilt on every request
`/predict` downloaded four objects from S3 and deserialised them on **every call**.

| Baseline (original code) | Req/s achieved | p50 | p95 |
|---|---|---|---|
| Flask dev server, 20 clients | 19 | 0.7 s | 1.0 s |
| Flask dev server, 50 clients | 21 | 2.3 s | 2.9 s |
| Flask dev server, 100 clients | 19 | 4.9 s | 6.2 s |
| gunicorn sync x4, 50 clients | 31 | 1.6 s | 1.9 s |
| gunicorn sync x4, 100 clients | 27 | 3.5 s | 4.3 s |

Throughput plateaued at ~20–30 req/s; extra clients only increased queueing delay (latency grew
roughly linearly with client count). Adding gunicorn workers helped only marginally because the cost
was per-request I/O and deserialisation, not the web server.

**Fix:** per-user in-memory cache with single-flight loading (a per-user lock so concurrent misses
trigger one load). Freshness is checked with an S3 `HEAD` on a marker object at most every 10 s, and
the marker's ETag is the cache version. Training uploads the marker **last**, so a cached copy is
never a half-written model set.

### 3.2 Race condition: readers vs. writer on shared files
Under predict + retrain load (20 predict clients + 3 clients retraining the same user, 90 s):
one `/predict` returned HTTP 500 with `Unable to synchronously open file (unable to lock file...)`
because training rewrote a file at the same local path a request was reading. Two concurrent
retrains of the same user could also interleave writes to the same local files and S3 keys.

**Fix:**
- Each load and each training run uses its own private temp directory (no shared mutable paths).
- A per-user `flock` ensures one training run per user. A second request gets `409 already_running`.
- The lock file descriptor is passed to the child process, so the lock is never released in the
  gap between the HTTP handler and the worker starting. (A first version released it early and let
  two back-to-back requests both return 202 — caught by testing and fixed.)

### 3.3 Long work inside the request thread
`/retrain` and `/add_user` blocked an HTTP worker for 8–18 s (`subprocess.run`, no timeout).
During the mixed test baseline retrain requests had p50 12 s / max 17.7 s and dragged predict p50
up to ~2 s.

**Fix:** training runs as a detached background process. `/retrain` and `/add_user` return `202`
immediately; progress is available from `GET /status/<user_id>`
(`{"running": bool, "last": {"ok", "rows", "seconds", ...}}`).

### 3.4 Silent data truncation
`retrain.py` made a single `list_objects_v2` call, which returns at most 1,000 keys. Reproduced with
1,500 stored sessions: training saw 1,000 and `IsTruncated=True` was ignored. It also fetched each
object sequentially.

**Fix:** paginated listing and 16-way parallel reads.

### 3.5 Input handling and information leakage
- `user_id` went unvalidated into filesystem paths and S3 keys → now `^[A-Za-z0-9_-]{1,64}$`.
- Missing/invalid JSON or fields caused `KeyError` → HTTP 500 with the raw exception string.
  Now `400` with a short message; unknown user → `404`; stack traces go to logs only.
- Upload temp files used shared `/tmp/<filename>` (collisions between concurrent uploads) → unique
  temp files that are deleted after upload.
- Session object keys used second-resolution timestamps (possible overwrite under load) →
  nanosecond timestamps.

### 3.6 Secret in source
A Telegram bot token and chat ID were hardcoded in `retrain.py` and exist in git history. The code
now reads `TELEGRAM_TOKEN` / `TELEGRAM_CHAT_ID` from the environment, and notification failures are
logged instead of swallowed.
**Action still required:** revoke/rotate the old token (removing it from the file does not remove
it from history).

## 4. Results after the changes

| After (this branch) | Req/s achieved | p50 | p95 | p99 | Failures |
|---|---|---|---|---|---|
| gunicorn sync x4, 50 clients | 50 | 78 ms | 120 ms | 350 ms | 0 |
| gunicorn sync x4, 100 clients | 101 | 140 ms | 310 ms | 700 ms | 0 |
| gunicorn gthread 4x8, 100 clients | 99 | 160 ms | 280 ms | 400 ms | 0 |
| gunicorn gthread 4x8, 300 clients | 280 | 320 ms | 550 ms | 600 ms | 0 |
| Mixed: 20 predict + 3 retrain clients | 20 | 38 ms | 140 ms | 180 ms | 0 |

Like-for-like (gunicorn sync x4, same load): at 100 clients throughput went from 27 to 101 req/s and
p50 from 3.5 s to 140 ms. In the mixed scenario predict p50 went from ~2 s to 38 ms, the file-lock
500 did not recur, and retrain requests return in ~60 ms (they either start a job or get a 409).

Notes on the numbers:
- At 300 clients, gunicorn's default **sync** workers produced connection-level errors on ~35% of
  requests (client status 0, nothing in the server log). Threaded workers (`-k gthread`) removed
  them. The cause of the sync-worker drops was not investigated further. `run.sh` uses gthread.
- In the mixed run the Locust "failures" for `/retrain` were only the intended `202`/`409`
  responses; the checker was corrected to accept them.

## 5. Not fixed / known limits

- **No authentication or TLS.** Anyone who can reach the port can call every endpoint, including
  `/add_user` and `/retrain` for any user.
- **Pickle/HDF5 deserialisation of objects from S3.** Anyone with write access to the bucket can
  achieve code execution on the server. Restrict the IAM role/bucket policy and consider safer
  formats.
- **Single-host assumptions.** The file lock and cache are per machine. Multiple instances would
  need a shared lock (e.g. DynamoDB conditional write); the S3 version check already keeps caches
  consistent.
- **Sessions are stored and used for retraining without review**, so a hostile client can influence
  future training data. This is a design issue, not addressed here.
- **Privacy/retention:** GPS and device data accumulate in S3 with no retention policy or
  per-user delete.
- **Measurement limits:** local test, mocked S3, synthetic data, one machine for both client and
  server. Re-run `run.sh` against a staging instance with real S3 before quoting production numbers.

## 6. Using this for resume bullets

Choose 2–3 and keep the qualifiers; they are what make the claims defensible.

- Load-tested a Flask REST service with Locust (up to 300 concurrent clients); traced a throughput
  ceiling (~27 req/s) to per-request S3 downloads and deserialisation, and added a per-user cache
  with single-flight loading and ETag-based invalidation, reaching ~100 req/s at 100 clients with
  p50 latency down from 3.5 s to 140 ms (local benchmark, mocked S3).
- Diagnosed and fixed a read/write race that caused intermittent HTTP 500s during concurrent
  retraining: private working directories, per-user `flock` (409 on conflict), and a "complete
  marker uploaded last" convention for versioned S3 artifacts.
- Moved long-running work (8–18 s) out of the HTTP request path into background jobs with 202
  responses and a status endpoint, cutting request p50 under mixed load from ~2 s to 38 ms.
- Found and fixed silent data loss from unpaginated S3 `list_objects_v2` (1,000-key cap) and added
  parallel reads; added input validation, removed a hardcoded API token from source, and replaced
  raw-exception 500s with proper 4xx responses.
- Built a reproducible benchmark harness (moto + gunicorn + Locust, one command) and wrote up the
  audit with before/after measurements.

**Accuracy checklist before you use these:**
1. Say "local benchmark" or "mocked S3". Do not imply production traffic.
2. Quote like-for-like comparisons (same server type, same client count). The 280 req/s figure is
   a different server configuration and client count than the 27 req/s baseline.
3. Do not claim authentication, TLS, or protection against malicious training data. Those are open.
4. Describe your role truthfully (audited/optimised vs. built from scratch).
5. Be ready for follow-ups: why a per-process cache is safe here (ETag check), why `flock` and not
   a database lock (single host), and what you would change for multiple instances.
