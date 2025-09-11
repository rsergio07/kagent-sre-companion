#!/usr/bin/env bash
set -euo pipefail

echo "[+] Deploying core Kubernetes infrastructure"

# Core application components
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment-blue.yaml
kubectl apply -f k8s/deployment-green.yaml
kubectl apply -f k8s/service.yaml

echo "[+] Core infrastructure deployed"
echo "Blue deployment: 2 replicas (active)"
echo "Green deployment: 0 replicas (standby)"

# Show service URL
minikube service web -n sre-companion-demo --url
