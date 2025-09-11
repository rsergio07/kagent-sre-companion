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

validate_anthropic_key() {
    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        echo "ERROR: ANTHROPIC_API_KEY environment variable is required"
        echo "Please set it with: export ANTHROPIC_API_KEY='your-api-key-here'"
        exit 1
    fi
    echo "[+] Anthropic API key validated"
}

check_existing_runtime() {
    if minikube status >/dev/null 2>&1; then
        echo "[!] Minikube already running, stopping first..."
        minikube stop
    fi
    
    # Check if Colima is available and handle it properly
    if command -v colima >/dev/null 2>&1; then
        echo "[+] Configuring Colima for adequate resources..."
        
        # Stop any existing Colima instance
        if colima status >/dev/null 2>&1; then
            echo "[!] Stopping existing Colima instance..."
            colima stop
        fi
        
        # Delete existing instance to avoid conflicts
        echo "[+] Cleaning up existing Colima instance..."
        colima delete --force >/dev/null 2>&1 || true
        
        # Start fresh with proper resources
        echo "[+] Starting fresh Colima instance with proper resource allocation..."
        if ! colima start --cpu 8 --memory 16 --disk 60 --vm-type vz; then
            echo "[!] VZ driver failed, trying with qemu..."
            colima start --cpu 8 --memory 16 --disk 60 --vm-type qemu
        fi
        
        # Wait for Docker to be available
        echo "[+] Waiting for Docker daemon to be ready..."
        for i in {1..30}; do
            if docker info >/dev/null 2>&1; then
                echo "[✓] Docker daemon is ready"
                break
            fi
            echo "    Waiting for Docker... ($i/30)"
            sleep 2
        done
        
        if ! docker info >/dev/null 2>&1; then
            echo "ERROR: Docker daemon failed to start after 60 seconds"
            exit 1
        fi
        
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
        kubectl delete namespace sre-companion-demo --ignore-not-found
    fi
}
trap cleanup EXIT

# Main installation
main() {
    validate_prerequisites
    validate_anthropic_key
    check_existing_runtime

    echo "[+] Starting Minikube with adequate resources (within Colima limits)"
    # Use 6 CPUs and 12GB RAM to stay within Colima's 8 CPU / 16GB allocation
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
    --set providers.anthropic.apiKey="${ANTHROPIC_API_KEY}" \
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