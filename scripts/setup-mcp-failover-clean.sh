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

check_existing_runtime() {
    if minikube status >/dev/null 2>&1; then
        echo "[!] Minikube already running, stopping first..."
        minikube stop
    fi
    
    # Check if Colima is running and configure it properly
    if command -v colima >/dev/null 2>&1; then
        echo "[+] Configuring Colima for adequate resources..."
        if colima status >/dev/null 2>&1; then
            echo "[!] Stopping Colima to reconfigure..."
            colima stop
        fi
        echo "[+] Starting Colima with proper resource allocation..."
        colima start --cpu 8 --memory 16 --disk 60
        echo "[+] Colima configured successfully"
    elif docker info >/dev/null 2>&1; then
        echo "[+] Docker runtime detected (not Colima)"
    else
        echo "ERROR: No Docker runtime available. Please install Docker Desktop or Colima"
        exit 1
    fi
}

wait_for_deployment() {
    local name=$1 namespace=$2 timeout=${3:-300}
    echo "[+] Waiting for $name deployment to be ready (${timeout}s timeout)..."
    if ! kubectl wait --for=condition=available --timeout=${timeout}s deployment/$name -n $namespace; then
        echo "ERROR: $name failed to become ready within ${timeout}s"
        echo "--- Pod Status ---"
        kubectl -n $namespace get pods -l app.kubernetes.io/name=$name
        echo "--- Deployment Description ---"
        kubectl -n $namespace describe deployment $name
        echo "--- Recent Events ---"
        kubectl -n $namespace get events --sort-by='.lastTimestamp' | tail -10
        exit 1
    fi
    echo "[✓] $name is ready"
}

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "[!] Script failed. Cleaning up..."
        kubectl delete namespace mcp-failover-clean --ignore-not-found
    fi
}
trap cleanup EXIT

# Main installation
main() {
    validate_prerequisites
    validate_openai_key
    check_existing_runtime

    echo "[+] Starting Minikube with adequate resources (within Colima limits)"
    # Use 6 CPUs and 12GB RAM to stay within Colima's 8 CPU / 16GB allocation
    minikube start --cpus=6 --memory=12288mb --disk-size=40g --driver=docker
    
    echo "[+] Cleaning old namespaces"
    kubectl delete namespace mcp-failover-clean --ignore-not-found
    kubectl create namespace mcp-failover-clean
    
    echo "[+] Ensuring resilience-demo image is available offline"
    IMAGE_TAG="resilience-demo:1.1"
    APP_TAR="images/resilience-demo_1.1.tar"

    if docker image inspect "${IMAGE_TAG}" >/dev/null 2>&1; then
        echo "[✓] Found ${IMAGE_TAG} in local Docker cache"
    elif [[ -f "${APP_TAR}" ]]; then
        echo "[+] Loading app image from TAR: ${APP_TAR}"
        docker load -i "${APP_TAR}"
    else
        echo "[!] WARNING: App image ${IMAGE_TAG} not found and ${APP_TAR} missing"
        echo "    The demo will attempt to pull the image from a registry (requires internet)"
    fi

    echo "[+] Preloading app image into Minikube"
    minikube image load "${IMAGE_TAG}" || true
    
    echo "[+] Deploying demo workloads (blue/green)"
    kubectl apply -n mcp-failover-clean -f ./mcp-failover-clean/k8s/deployment-blue.yaml
    kubectl apply -n mcp-failover-clean -f ./mcp-failover-clean/k8s/deployment-green.yaml
    kubectl apply -n mcp-failover-clean -f ./mcp-failover-clean/k8s/service.yaml

    echo "[setup] Installing Prometheus stack via Helm..."
    helm install prom-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring --create-namespace \
    -f ./mcp-failover-clean/k8s/monitoring/values.yaml

    echo "[+] Installing kagent CLI (user mode)"
    mkdir -p ./bin
    curl -sL https://cr.kagent.dev/v0.5.5/kagent-darwin-arm64 -o ./bin/kubectl-kagent
    chmod +x ./bin/kubectl-kagent
    export PATH="$(pwd)/bin:$PATH"
    
    echo "[+] Installing kagent CRDs"
    helm install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
    --version 0.5.5 --namespace kagent --create-namespace --wait
    
    echo "[+] Installing KMCP CRDs"
    helm install kmcp-crds oci://ghcr.io/kagent-dev/kmcp/helm/kmcp-crds \
    --version 0.1.5 --namespace kmcp-system --create-namespace --wait
    
    echo "[+] Creating OpenAI secret securely"
    kubectl delete secret openai-secret -n kagent --ignore-not-found
    kubectl create secret generic openai-secret -n kagent \
    --from-literal=api-key="${OPENAI_API_KEY}"
    
    echo "[+] Installing Kagent core components"
    helm install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
    --version 0.5.5 --namespace kagent \
    --set providers.openAI.apiKey="${OPENAI_API_KEY}" \
    --wait --timeout=10m
    
    # Wait for controller to be fully ready
    wait_for_deployment kagent-controller kagent 300
    
    echo "[+] Verifying all CRDs are available"
    kubectl get crd | grep kagent
    
    # Check if sessions CRD exists
    if kubectl get crd sessions.kagent.dev >/dev/null 2>&1; then
        echo "[✓] sessions.kagent.dev CRD found"
        SESSION_CRD_EXISTS=true
    else
        echo "[!] sessions.kagent.dev CRD not found - will skip session.yaml"
        SESSION_CRD_EXISTS=false
    fi
    
    echo "[+] Applying kagent configurations"
    kubectl apply -f ./mcp-failover-clean/k8s/modelconfig.yaml
    kubectl apply -f ./mcp-failover-clean/k8s/mcpserver.yaml
    kubectl apply -f ./mcp-failover-clean/k8s/memory.yaml
    kubectl apply -f ./mcp-failover-clean/k8s/agent.yaml
    
    # Check if session.yaml exists and if Session CRD is available
    if [[ -f "./mcp-failover-clean/k8s/session.yaml" ]]; then
        if kubectl get crd sessions.kagent.dev >/dev/null 2>&1; then
            kubectl apply -f ./mcp-failover-clean/k8s/session.yaml
            echo "[✓] Session configuration applied"
        else
            echo "[!] Session CRD not available in kagent v0.5.5 - skipping session.yaml"
            echo "    This is likely due to Session resources being deprecated or moved"
            echo "    The demo should work without explicit Session resources"
        fi
    else
        echo "[!] session.yaml file not found - skipping"
    fi
    
    kubectl apply -f ./mcp-failover-clean/k8s/failover-agent-config.yaml

    echo "[+] Deploying autonomous failover controller"
    kubectl apply -f ./mcp-failover-clean/k8s/failover-controller.yaml

    # Wait for the controller to be ready
    wait_for_deployment failover-controller mcp-failover-clean 120

    echo "[+] Verifying failover controller is monitoring"
    sleep 5
    kubectl logs deployment/failover-controller -n mcp-failover-clean --tail=10
    
    echo ""
    echo "Installation completed successfully!"
    echo ""
    echo "NEXT STEPS:"
    echo "1. Wait for agent pods: kubectl -n kagent get pods"
    echo "2. Get app URL: minikube service web -n mcp-failover-clean --url"
    echo "3. Open Kagent dashboard: ./bin/kubectl-kagent dashboard"
    echo ""
    echo "Blue deployment: 2 replicas (active)"
    echo "Green deployment: 0 replicas (standby)"
}

main "$@"