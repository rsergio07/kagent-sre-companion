#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    echo "ERROR: OPENAI_API_KEY environment variable is required"
    exit 1
fi

echo "[+] Deploying kagent AI integration"

# Apply kagent configurations
kubectl apply -f kagent/modelconfig.yaml
kubectl apply -f kagent/mcpserver.yaml
kubectl apply -f kagent/memory.yaml
kubectl apply -f kagent/agent.yaml

# Check if session.yaml exists and apply
if [[ -f "kagent/session.yaml" ]]; then
    kubectl apply -f kagent/session.yaml || echo "[!] Session CRD may not be available"
fi

kubectl apply -f kagent/failover-agent-config.yaml

echo "[+] kagent AI integration deployed"
echo "Access kagent dashboard: kubectl -n kagent port-forward service/kagent-ui 8080:80"
