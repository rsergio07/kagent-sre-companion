#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/load-test.sh [duration] [concurrency] [burn-ms]
DURATION="${1:-120}"
CONCURRENCY="${2:-150}"
BURN_MS="${3:-500}"
NAMESPACE="sre-companion-demo"
LOCAL_PORT="${PORT:-18080}"

echo "[+] Starting load test: ${DURATION}s duration, ${CONCURRENCY} concurrency"
kubectl -n "$NAMESPACE" port-forward svc/web "${LOCAL_PORT}:80" >/dev/null 2>&1 &
PF_PID=$!
trap 'echo "[+] Stopping port-forward"; kill ${PF_PID} 2>/dev/null || true' EXIT

sleep 2
URL="http://127.0.0.1:${LOCAL_PORT}/work?ms=${BURN_MS}&n=50"

# Main load generation
END=$((SECONDS + DURATION))
while (( SECONDS < END )); do
  for _ in $(seq 1 "$CONCURRENCY"); do
    curl -s -o /dev/null "$URL" &
  done
  sleep 0.2
done

wait || true
echo "[+] Load test completed"
