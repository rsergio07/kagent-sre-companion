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

force_cleanup() {
    echo "[+] Performing force cleanup of existing environments..."
    
    # Force delete Minikube cluster completely
    echo "[+] Force deleting any existing Minikube clusters..."
    minikube delete --all --purge 2>/dev/null || true
    
    # Clean up Docker contexts that might be pointing to Colima
    echo "[+] Resetting Docker context..."
    docker context use default 2>/dev/null || true
    
    # Stop Colima if running
    if command -v colima >/dev/null 2>&1; then
        echo "[+] Stopping Colima..."
        colima stop 2>/dev/null || true
    fi
    
    # Clean up any stale kubectl contexts
    kubectl config unset current-context 2>/dev/null || true
    kubectl config delete-context minikube 2>/dev/null || true
    kubectl config delete-cluster minikube 2>/dev/null || true
    
    echo "[+] Force cleanup completed"
}

setup_docker_runtime() {
    echo "[+] Setting up Docker runtime..."
    
    # Check if Docker Desktop is available and running
    if docker info >/dev/null 2>&1; then
        DOCKER_DRIVER=$(docker info --format '{{.ServerVersion}}' 2>/dev/null || echo "unknown")
        echo "[+] Docker is already running (version: $DOCKER_DRIVER)"
        return 0
    fi
    
    # Try to start Docker Desktop
    echo "[+] Attempting to start Docker Desktop..."
    if [[ -d "/Applications/Docker.app" ]]; then
        open -a Docker
        echo "[+] Docker Desktop starting... waiting for it to be ready"
        
        # Wait for Docker to be ready (up to 2 minutes)
        for i in {1..60}; do
            if docker info >/dev/null 2>&1; then
                echo "[+] Docker Desktop is ready"
                return 0
            fi
            echo "    Waiting for Docker Desktop... ($i/60)"
            sleep 2
        done
        
        echo "ERROR: Docker Desktop failed to start within 2 minutes"
        exit 1
    fi
    
    # If Docker Desktop is not available, try Colima
    if command -v colima >/dev/null 2>&1; then
        echo "[+] Docker Desktop not found, trying Colima..."
        colima delete --force 2>/dev/null || true
        
        echo "[+] Starting Colima with adequate resources..."
        if ! colima start --cpu 8 --memory 16 --disk 60 --vm-type vz 2>/dev/null; then
            echo "[!] VZ driver failed, trying QEMU..."
            colima start --cpu 8 --memory 16 --disk 60 --vm-type qemu
        fi
        
        # Wait for Docker to be available through Colima
        for i in {1..30}; do
            if docker info >/dev/null 2>&1; then
                echo "[+] Colima Docker is ready"
                return 0
            fi
            echo "    Waiting for Colima Docker... ($i/30)"
            sleep 2
        done
        
        echo "ERROR: Colima Docker failed to start"
        exit 1
    fi
    
    echo "ERROR: Neither Docker Desktop nor Colima is available"
    exit 1
}

wait_for_deployment() {
    local name=$1 namespace=$2 timeout=${3:-300}
    echo "[+] Waiting for $name deployment to be ready (${timeout}s timeout)..."
    if ! kubectl wait --for=condition=available --timeout=${timeout}s deployment/$name -n $namespace; then
        echo "ERROR: $name failed to become ready within ${timeout}s"
        echo "--- Pod Status ---"
        kubectl -n $namespace get pods || true
        echo "--- Events ---"
        kubectl -n $namespace get events --sort-by='.lastTimestamp' | tail -10 || true
        exit 1
    fi
    echo "[✓] $name is ready"
}

# Main installation
main() {
    validate_prerequisites
    validate_anthropic_key
    
    # Force cleanup any existing state
    force_cleanup
    
    # Setup Docker runtime
    setup_docker_runtime
    
    # Verify Docker is working
    echo "[+] Verifying Docker connectivity..."
    if ! docker ps >/dev/null 2>&1; then
        echo "ERROR: Docker is not responding properly"
        exit 1
    fi
    
    echo "[+] Starting fresh Minikube cluster..."
    minikube start --cpus=6 --memory=12288mb --disk-size=40g --driver=docker --force
    
    # Verify Minikube is working
    echo "[+] Verifying Minikube cluster..."
    kubectl get nodes
    kubectl cluster-info
    
    echo "[+] Building and loading demo application image..."
    docker build -t resilience-demo:1.1 .
    minikube image load resilience-demo:1.1
    
    echo "[+] Deploying core infrastructure"
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/deployment-blue.yaml
    kubectl apply -f k8s/deployment-green.yaml
    kubectl apply -f k8s/service.yaml

    echo "[+] Adding Helm repositories..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    echo "[+] Installing Prometheus stack via Helm"
    helm install prom-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring --create-namespace \
    -f kagent/monitoring/values.yaml \
    --wait --timeout=10m

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
    
    # Handle session.yaml gracefully
    if [[ -f "kagent/session.yaml" ]] && kubectl get crd sessions.kagent.dev >/dev/null 2>&1; then
        kubectl apply -f kagent/session.yaml
    else
        echo "[!] Skipping session.yaml (CRD not available or file missing)"
    fi
    
    kubectl apply -f kagent/failover-agent-config.yaml

    echo "[+] Deploying autonomous failover controller"
    kubectl apply -f controllers/failover-controller.yaml
    wait_for_deployment failover-controller sre-companion-demo 120

    echo ""
    echo "========================================="
    echo "✅ Installation completed successfully!"
    echo "========================================="
    echo ""
    echo "NEXT STEPS:"
    echo "1. Check all pods: kubectl get pods --all-namespaces"
    echo "2. Get app URL: minikube service web -n sre-companion-demo --url"
    echo "3. Open kagent dashboard: kubectl -n kagent port-forward service/kagent-ui 8080:80"
    echo ""
    echo "Blue deployment: 2 replicas (active)"
    echo "Green deployment: 0 replicas (standby)"
    echo ""
    echo "To test failover: kubectl scale deployment web-blue --replicas=0 -n sre-companion-demo"
    echo "To load test: ./scripts/load-test.sh"
}

main "$@"