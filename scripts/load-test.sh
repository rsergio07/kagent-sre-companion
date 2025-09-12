#!/usr/bin/env bash
set -euo pipefail
# Usage:
#   ./scripts/load-test.sh             # 120s, 150 concurrency, 500ms burn
#   ./scripts/load-test.sh 180 250 700 # duration, concurrency, burn-ms
DURATION="${1:-120}"
CONCURRENCY="${2:-150}"
BURN_MS="${3:-500}"
NAMESPACE="sre-companion-demo"  # Updated for current demo
LOCAL_PORT="${PORT:-18080}"

# Start a background port-forward to the Service (works on Docker driver / macOS)
echo "[+] Starting port-forward svc/web -> localhost:${LOCAL_PORT}"
kubectl -n "$NAMESPACE" port-forward svc/web "${LOCAL_PORT}:80" >/dev/null 2>&1 &
PF_PID=$!
trap 'echo "[+] Stopping port-forward (pid ${PF_PID})"; kill ${PF_PID} 2>/dev/null || true' EXIT

# Give the port-forward a moment to bind
sleep 2
URL="http://127.0.0.1:${LOCAL_PORT}/work?ms=${BURN_MS}&n=50"
echo "[+] Target URL: ${URL}"
echo "[+] Duration: ${DURATION}s | Concurrency: ${CONCURRENCY} | Burn: ${BURN_MS}ms"
echo "[i] Press Ctrl+C to stop early."

# Warm-up (helps metrics pick up CPU quickly)
for _ in $(seq 1 50); do curl -s -o /dev/null "$URL" & done
wait || true

# Main sustained load
END=$((SECONDS + DURATION))
while (( SECONDS < END )); do
  for _ in $(seq 1 "$CONCURRENCY"); do
    curl -s -o /dev/null "$URL" &
  done
  sleep 0.2
done

wait || true
echo "[+] Load test finished."