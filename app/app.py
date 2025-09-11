from flask import Flask, render_template, request
import os
import socket
import time
import math
from datetime import datetime

app = Flask(__name__)

COLOR = os.getenv("COLOR", "#0ea5e9")   # default sky blue
REGION = os.getenv("REGION", "blue")
VERSION = os.getenv("VERSION", "v1.0.0")

@app.route("/")
def index():
    hostname = socket.gethostname()
    now = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    return render_template(
        "index.html",
        color=COLOR,
        region=REGION,
        hostname=hostname,
        version=VERSION,
        timestamp=now
    )

@app.route("/healthz")
def health():
    # Liveness probe target
    return "ok", 200

@app.route("/readyz")
def ready():
    # Readiness probe target
    return "ready", 200

@app.route("/work")
def work():
    """
    CPU burn to trigger scaling demonstrations.
    Usage:
      /work?ms=200      -> burn ~200ms
      /work?ms=500&n=50 -> burn ~500ms with more inner loops
    """
    ms = max(1, int(request.args.get("ms", "200")))
    n = max(1, int(request.args.get("n", "20")))

    end = time.time() + (ms / 1000.0)
    x = 0.0
    while time.time() < end:
        # meaningless math to consume CPU cycles
        for _ in range(n):
            x = math.sqrt((x + 1.234567) * 3.14159) + 2.71828
    return "ok", 200

if __name__ == "__main__":
    # Flask dev server (sufficient for demo)
    app.run(host="0.0.0.0", port=8080)
