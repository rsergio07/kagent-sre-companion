#!/usr/bin/env bash
set -euo pipefail

echo "[+] Deploying autonomous controllers"

kubectl apply -f controllers/failover-controller.yaml

echo "[+] Waiting for failover controller to be ready"
kubectl wait --for=condition=available --timeout=120s deployment/failover-controller -n sre-companion-demo

echo "[+] Autonomous controllers deployed and ready"
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=5
