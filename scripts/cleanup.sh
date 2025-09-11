#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sre-companion-demo"

echo "[+] Cleaning up SRE companion demo environment"

# Force cleanup Minikube first (this handles stuck states)
if command -v minikube >/dev/null 2>&1; then
    echo "[+] Force cleaning Minikube..."
    minikube delete --all --purge 2>/dev/null || true
    echo "[+] Minikube cleanup completed"
else
    echo "[!] Minikube not found - skipping"
fi

# Clean up kubectl contexts
echo "[+] Cleaning kubectl contexts..."
kubectl config unset current-context 2>/dev/null || true
kubectl config delete-context minikube 2>/dev/null || true
kubectl config delete-cluster minikube 2>/dev/null || true

# Reset Docker context
echo "[+] Resetting Docker context..."
docker context use default 2>/dev/null || true

# Clean up Colima if it exists and is running
if command -v colima >/dev/null 2>&1; then
    if colima status >/dev/null 2>&1; then
        echo "[+] Stopping Colima..."
        colima stop 2>/dev/null || true
        echo "[+] Colima stopped (not deleted - may be used by other projects)"
    else
        echo "[!] Colima not running - skipping"
    fi
else
    echo "[!] Colima not found - skipping"
fi

# Clean up local artifacts
echo "[+] Cleaning up local artifacts..."
rm -rf ./bin/ || true
rm -f ./images/*.tar || true

echo "[+] Cleanup completed successfully"
echo "[+] Environment is clean and ready for fresh deployment"