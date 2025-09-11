#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "kagent SRE Companion Progressive Setup"
echo "========================================"

# Validation functions
validate_prerequisites() {
    echo "[+] Checking prerequisites..."
    command -v kubectl >/dev/null || { echo "ERROR: kubectl is required"; exit 1; }
    command -v helm >/dev/null || { echo "ERROR: helm is required"; exit 1; }
    command -v minikube >/dev/null || { echo "ERROR: minikube is required"; exit 1; }
    command -v docker >/dev/null || { echo "ERROR: docker is required"; exit 1; }
}

validate_anthropic_key() {
    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        echo "ERROR: ANTHROPIC_API_KEY environment variable is required"
        echo "Please set it with: export ANTHROPIC_API_KEY='your-api-key-here'"
        exit 1
    fi
    echo "[+] Anthropic API key validated"
}

echo ""
echo "Phase 1: Prerequisites and Cluster Setup"
echo "----------------------------------------"
validate_prerequisites
validate_anthropic_key

echo "[+] Starting Minikube cluster"
minikube start --cpus=4 --memory=8192mb --disk-size=20g --driver=docker

echo ""
echo "Phase 2: Core Infrastructure"
echo "----------------------------"
./scripts/deploy-core.sh

echo ""
echo "Phase 3: Install kagent Platform"
echo "--------------------------------"
echo "[+] Installing kagent CRDs and platform"
helm install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
--version 0.5.5 --namespace kagent --create-namespace --wait

helm install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
--version 0.5.5 --namespace kagent \
--set providers.anthropic.apiKey="${ANTHROPIC_API_KEY}" \
--wait --timeout=10m

echo ""
echo "Phase 4: AI Integration"
echo "----------------------"
./scripts/deploy-kagent.sh

echo ""
echo "Phase 5: Autonomous Controllers"
echo "------------------------------"
./scripts/deploy-controllers.sh

echo ""
echo "========================================="
echo "✅ SRE Companion Demo Ready!"
echo "========================================="
echo ""
echo "DEMO INTERFACES:"
echo "1. Application: $(minikube service web -n sre-companion-demo --url)"
echo "2. kagent Dashboard: kubectl -n kagent port-forward service/kagent-ui 8080:80"
echo ""
echo "DEMO PROGRESSION:"
echo "• Core Infrastructure: Traditional blue/green setup"
echo "• AI Integration: kagent SRE companion"  
echo "• Autonomous Operations: Self-healing controllers"
echo ""

