#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sre-companion-demo"

echo "[+] Cleaning up SRE companion demo environment"

# Check if kubectl can connect to a cluster
if kubectl cluster-info >/dev/null 2>&1; then
    echo "[+] Kubernetes cluster detected, cleaning up resources..."
    
    # Delete demo namespace (cascades to all resources)
    kubectl delete namespace "$NAMESPACE" --ignore-not-found
    
    # Clean up kagent components if needed
    kubectl delete namespace kagent --ignore-not-found || true
    kubectl delete namespace kmcp-system --ignore-not-found || true
    kubectl delete namespace monitoring --ignore-not-found || true
    
    echo "[+] Kubernetes resources cleaned up"
else
    echo "[!] No Kubernetes cluster available - skipping kubectl cleanup"
fi

# Stop and clean up Minikube if it exists
if command -v minikube >/dev/null 2>&1; then
    if minikube status >/dev/null 2>&1; then
        echo "[+] Stopping Minikube..."
        minikube stop
        echo "[+] Deleting Minikube cluster..."
        minikube delete
    else
        echo "[!] Minikube not running - skipping"
    fi
else
    echo "[!] Minikube not found - skipping"
fi

# Clean up Colima if it exists and is running
if command -v colima >/dev/null 2>&1; then
    if colima status >/dev/null 2>&1; then
        echo "[+] Stopping Colima..."
        colima stop
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