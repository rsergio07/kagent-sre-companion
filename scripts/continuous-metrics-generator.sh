#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sre-companion-demo"
LOCAL_PORT="${PORT:-18080}"

echo "Starting Continuous Metrics Generator"
echo "Press Ctrl+C to stop gracefully"
echo "----------------------------------------"

# Global cleanup function
cleanup() {
    echo ""
    echo "Cleaning up continuous metrics generator..."
    
    # Kill all background processes
    jobs -p | xargs -r kill 2>/dev/null || true
    
    # Kill port-forward processes
    pkill -f "port-forward.*${LOCAL_PORT}" 2>/dev/null || true
    
    # Kill any remaining curl processes
    pkill -f "curl.*${LOCAL_PORT}" 2>/dev/null || true
    
    # Reset deployment to normal
    kubectl scale deployment web-blue --replicas=2 -n "$NAMESPACE" 2>/dev/null || true
    
    echo "Cleanup complete. Exiting..."
    exit 0
}

# Set up signal handling
trap cleanup EXIT INT TERM

# Start port-forward once
echo "Setting up port forwarding..."
kubectl -n "$NAMESPACE" port-forward svc/web "${LOCAL_PORT}:80" >/dev/null 2>&1 &
PF_PID=$!

sleep 3

# URL for load testing
URL="http://127.0.0.1:${LOCAL_PORT}/work"

# Function to generate burst load pattern
generate_burst_load() {
    local intensity=$1
    local duration=$2
    local burn_ms=$3
    
    echo "  Burst load: intensity=$intensity, duration=${duration}s, burn=${burn_ms}ms"
    
    END_TIME=$(($(date +%s) + duration))
    while [ $(date +%s) -lt $END_TIME ]; do
        for _ in $(seq 1 $intensity); do
            curl -s -m 3 -o /dev/null "${URL}?ms=${burn_ms}&n=50" 2>/dev/null &
        done
        sleep 0.5
        
        # Prevent too many background jobs
        if [ $(jobs -r | wc -l) -gt 300 ]; then
            sleep 1
        fi
    done
}

# Function to create scaling spikes
create_scaling_spike() {
    local max_replicas=$1
    echo "  Scaling spike: up to $max_replicas replicas"
    
    kubectl scale deployment web-blue --replicas=$max_replicas -n "$NAMESPACE" 2>/dev/null || true
    sleep 45
    kubectl scale deployment web-blue --replicas=1 -n "$NAMESPACE" 2>/dev/null || true
    sleep 30
    kubectl scale deployment web-blue --replicas=2 -n "$NAMESPACE" 2>/dev/null || true
}

# Function to create pod restart avalanche
create_restart_avalanche() {
    echo "  Pod restart avalanche"
    kubectl delete pods -l app=web,version=blue -n "$NAMESPACE" --wait=false 2>/dev/null || true
    sleep 45  # Wait for pods to restart
}

# Main continuous loop
cycle=1
while true; do
    echo ""
    echo "Cycle $cycle - $(date '+%H:%M:%S')"
    echo "----------------------------------------"
    
    case $((cycle % 5)) in
        1)
            echo "Pattern: Light sustained load with scaling"
            generate_burst_load 50 90 300 &
            sleep 30
            create_scaling_spike 3
            ;;
        2)
            echo "Pattern: Memory pressure spikes"
            generate_burst_load 150 60 800 &
            sleep 90
            ;;
        3)
            echo "Pattern: Restart avalanche with heavy load"
            generate_burst_load 200 45 600 &
            sleep 20
            create_restart_avalanche
            ;;
        4)
            echo "Pattern: Rapid scaling with burst load"
            create_scaling_spike 4 &
            sleep 15
            generate_burst_load 250 75 1000 &
            wait
            ;;
        0)
            echo "Pattern: Maximum chaos - all patterns combined"
            generate_burst_load 300 30 1200 &
            sleep 15
            create_scaling_spike 5 &
            sleep 30
            create_restart_avalanche
            ;;
    esac
    
    # Cool down period between cycles
    echo "  Cooling down for 60 seconds..."
    sleep 60
    
    # Kill any remaining background curl processes from this cycle
    pkill -f "curl.*${LOCAL_PORT}" 2>/dev/null || true
    
    cycle=$((cycle + 1))
    
    # Optional: Limit total cycles to prevent infinite running
    if [ $cycle -gt 100 ]; then
        echo "Reached maximum cycles (100). Stopping..."
        break
    fi
done

cleanup