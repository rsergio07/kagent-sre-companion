#!/usr/bin/env bash
set -euo pipefail

# Validation functions
validate_prerequisites() {
    echo "[+] Checking prerequisites..."
    command -v kubectl >/dev/null || { echo "ERROR: kubectl is required"; exit 1; }
    command -v helm >/dev/null || { echo "ERROR: helm is required"; exit 1; }
    command -v minikube >/dev/null || { echo "ERROR: minikube is required"; exit 1; }
    command -v docker >/dev/null || { echo "ERROR: docker is required"; exit 1; }
}

validate_openai_key() {
    if [[ -z "${OPENAI_API_KEY:-}" ]]; then
        echo "ERROR: OPENAI_API_KEY environment variable is required"
        echo "Please set it with: export OPENAI_API_KEY='your-api-key-here'"
        exit 1
    fi
    echo "[+] OpenAI API key validated"
}

wait_for_deployment() {
    local name=$1 namespace=$2 timeout=${3:-300}
    echo "[+] Waiting for $name deployment to be ready (${timeout}s timeout)..."
    if ! kubectl wait --for=condition=available --timeout=${timeout}s deployment/$name -n $namespace; then
        echo "ERROR: $name failed to become ready within ${timeout}s"
        exit 1
    fi
    echo "[✓] $name is ready"
}

# Main installation
main() {
    validate_prerequisites
    validate_openai_key

    echo "[+] Starting Minikube with adequate resources"
    minikube start --cpus=6 --memory=12288mb --disk-size=40g --driver=docker
    
    echo "[+] Deploying core infrastructure"
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/deployment-blue.yaml
    kubectl apply -f k8s/deployment-green.yaml
    kubectl apply -f k8s/service.yaml

    echo "[+] Installing Prometheus stack via Helm"
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install prom-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring --create-namespace \
    -f kagent/monitoring/values.yaml

    echo "[+] Installing kagent CRDs"
    helm install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
    --version 0.5.5 --namespace kagent --create-namespace --wait
    
    echo "[+] Installing KMCP CRDs"
    helm install kmcp-crds oci://ghcr.io/kagent-dev/kmcp/helm/kmcp-crds \
    --version 0.1.5 --namespace kmcp-system --create-namespace --wait
    
    echo "[+] Installing kagent core components"
    helm install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
    --version 0.5.5 --namespace kagent \
    --set providers.openAI.apiKey="${OPENAI_API_KEY}" \
    --wait --timeout=10m
    
    wait_for_deployment kagent-controller kagent 300
    
    echo "[+] Applying kagent configurations"
    kubectl apply -f kagent/modelconfig.yaml
    kubectl apply -f kagent/mcpserver.yaml
    kubectl apply -f kagent/memory.yaml
    kubectl apply -f kagent/agent.yaml
    
    if [[ -f "kagent/session.yaml" ]]; then
        kubectl apply -f kagent/session.yaml || echo "[!] Session CRD may not be available"
    fi
    
    kubectl apply -f kagent/failover-agent-config.yaml

    echo "[+] Deploying autonomous failover controller"
    kubectl apply -f controllers/failover-controller.yaml
    wait_for_deployment failover-controller sre-companion-demo 120

    echo ""
    echo "Installation completed successfully!"
    echo ""
    echo "NEXT STEPS:"
    echo "1. Wait for agent pods: kubectl -n kagent get pods"
    echo "2. Get app URL: minikube service web -n sre-companion-demo --url"
    echo "3. Open kagent dashboard: kubectl -n kagent port-forward service/kagent-ui 8080:80"
    echo ""
    echo "Blue deployment: 2 replicas (active)"
    echo "Green deployment: 0 replicas (standby)"
}

main "$@"
