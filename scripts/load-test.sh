#!/usr/bin/env bash
set -euo pipefail

DURATION="${1:-120}"
CONCURRENCY="${2:-150}"
BURN_MS="${3:-500}"
NAMESPACE="sre-companion-demo"
LOCAL_PORT="${PORT:-18080}"

echo "[+] Starting load test: ${DURATION}s duration, ${CONCURRENCY} concurrency"

# Start port-forward
kubectl -n "$NAMESPACE" port-forward svc/web "${LOCAL_PORT}:80" >/dev/null 2>&1 &
PF_PID=$!

# Enhanced cleanup
cleanup() {
    echo "[+] Cleaning up..."
    kill $PF_PID 2>/dev/null || true
    # Kill any remaining curl processes
    pkill -f "curl.*${LOCAL_PORT}" 2>/dev/null || true
    exit 0
}

trap cleanup EXIT INT TERM

sleep 2
URL="http://127.0.0.1:${LOCAL_PORT}/work?ms=${BURN_MS}&n=50"

echo "[+] Target URL: ${URL}"
echo "[+] Will run for exactly ${DURATION} seconds"

# Simple approach - run for exact duration then stop
(
    END_TIME=$(($(date +%s) + DURATION))
    while [ $(date +%s) -lt $END_TIME ]; do
        for _ in $(seq 1 $CONCURRENCY); do
            curl -s -m 5 -o /dev/null "$URL" 2>/dev/null &
        done
        sleep 0.2
        
        # Prevent too many background jobs
        if [ $(jobs -r | wc -l) -gt 500 ]; then
            sleep 0.5
        fi
    done
) &

LOAD_PID=$!

# Wait for the specified duration
sleep $DURATION

# Kill the load generation
kill $LOAD_PID 2>/dev/null || true

echo "[+] Load test completed after ${DURATION} seconds"
cleanup