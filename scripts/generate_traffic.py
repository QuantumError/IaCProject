# This script generates random traffic against the two static sites deployed in the
# /webfront module, to exercise MinIO's metrics for Grafana/Prometheus. It runs forever until
# manually stopped.

import os
import random
import time
import urllib.request
import urllib.error
from datetime import datetime, timezone

MINIO_ENDPOINT = os.environ.get("MINIO_ENDPOINT", "http://minio:9000")
SITE1_BUCKET = os.environ.get("SITE1_BUCKET", "my-sample-website")
SITE2_BUCKET = os.environ.get("SITE2_BUCKET", "my-sample-website-2")

MIN_INTERVAL = float(os.environ.get("MIN_INTERVAL_SECONDS", "0"))
MAX_INTERVAL = float(os.environ.get("MAX_INTERVAL_SECONDS", "60"))


TARGETS = (
    [(SITE1_BUCKET, p) for p in ["index.html", "error.html"]]
    + [(SITE2_BUCKET, p) for p in ["index.html", "error.html", "css/style.css", "js/app.js"]]
)


def fetch(bucket, path):
    url = f"{MINIO_ENDPOINT}/{bucket}/{path}"
    ts = datetime.now(timezone.utc).strftime("%H:%M:%S")
    try:
        with urllib.request.urlopen(url, timeout=5) as resp:
            print(f"[{ts}] GET {bucket}/{path} -> {resp.status}", flush=True)
    except urllib.error.HTTPError as e:
        print(f"[{ts}] GET {bucket}/{path} -> {e.code}", flush=True)
    except urllib.error.URLError as e:
        print(f"[{ts}] GET {bucket}/{path} -> FAILED ({e.reason})", flush=True)


def main():
    print(
        f"Traffic generator starting against {MINIO_ENDPOINT} "
        f"(random wait: {MIN_INTERVAL}-{MAX_INTERVAL}s per request)",
        flush=True,
    )
    print(f"  site1 bucket: {SITE1_BUCKET}", flush=True)
    print(f"  site2 bucket: {SITE2_BUCKET}", flush=True)

    while True:
        wait = random.uniform(MIN_INTERVAL, MAX_INTERVAL)
        time.sleep(wait)
        bucket, path = random.choice(TARGETS)
        fetch(bucket, path)

if __name__ == "__main__":
    main()