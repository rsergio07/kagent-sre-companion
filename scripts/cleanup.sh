#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sre-companion-demo"

echo "[+] Cleaning up SRE companion demo environment"

# Delete namespace (cascades to all resources)
kubectl delete namespace "$NAMESPACE" --ignore-not-found

# Clean up kagent components if needed
kubectl delete namespace kagent --ignore-not-found || true

echo "[+] Cleanup completed"
