# SRE Companion Demo: AI-Powered Operations with Kagent

This repository demonstrates how Kagent transforms traditional Site Reliability Engineering practices through AI-powered cluster operations. The demo showcases intelligent blue/green deployment management, autonomous failover capabilities, and conversational cluster operations using Claude AI.

Kagent enhances traditional SRE tools by providing intelligent operational insights, automated decision-making, and conversational interfaces that make complex cluster operations accessible to both experienced operators and teams new to Kubernetes.

## Table of Contents

1. [Quick Deployment](#quick-deployment)
2. [Architecture Overview](#architecture-overview)
3. [Configuration Files](#configuration-files)
4. [Demo Scenarios](#demo-scenarios)
5. [SRE Principles](#sre-principles)
6. [Validation Commands](#validation-commands)
7. [Troubleshooting](#troubleshooting)

## Quick Deployment

### Prerequisites

```bash
# Required tools: kubectl, helm, minikube, docker
export ANTHROPIC_API_KEY='your-api-key-here'

# Clone repository
git clone https://github.com/rsergio07/kagent-sre-companion
cd kagent-sre-companion
```

### Complete Environment Setup

```bash
# Single command deployment (10-15 minutes)
./scripts/setup-sre-companion.sh
```

This script deploys the complete environment including Kubernetes infrastructure, AI integration, and autonomous controllers.

### Access Points

```bash
# Application interface
kubectl -n sre-companion-demo port-forward service/web 8082:80
# Visit: http://localhost:8082

# Kagent AI dashboard
kubectl -n kagent port-forward service/kagent-ui 8081:80
# Visit: http://localhost:8081
```

## Architecture Overview

### Core Components

**Application Layer**: Flask web service with health endpoints and visual blue/green state indicators. Changes color and metadata based on active deployment environment.

**Kubernetes Infrastructure**: Blue/green deployment pattern with traffic routing via service selectors. Blue starts active (2 replicas), green remains standby (0 replicas).

**Autonomous Controller**: Python-based failover controller that monitors service health and automatically switches traffic routing when endpoint failures are detected.

**AI Integration**: Kagent platform with Claude AI providing conversational cluster operations, deployment strategy guidance, and intelligent operational insights.

**Monitoring Stack**: Prometheus, Grafana, and AlertManager for comprehensive observability and metrics collection.

### Deployment Flow

```bash
# Core infrastructure
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment-blue.yaml
kubectl apply -f k8s/deployment-green.yaml
kubectl apply -f k8s/service.yaml

# Monitoring stack
helm install prom-stack prometheus-community/kube-prometheus-stack \
--namespace monitoring --create-namespace

# Kagent platform
helm install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
--version 0.5.5 --namespace kagent --create-namespace --wait

helm install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
--version 0.5.5 --namespace kagent \
--set providers.anthropic.apiKey="${ANTHROPIC_API_KEY}"

# Agent configurations
kubectl apply -f kagent/modelconfig.yaml
kubectl apply -f kagent/mcpserver.yaml
kubectl apply -f kagent/memory.yaml
kubectl apply -f kagent/agent.yaml
kubectl apply -f kagent/failover-agent-config.yaml

# Autonomous controllers
kubectl apply -f controllers/failover-controller.yaml
```

## Configuration Files

### Application (`app/`)

- **app.py**: Flask application with `/healthz`, `/readyz`, and `/work` endpoints
- **requirements.txt**: Python dependencies (Flask, Gunicorn)
- **templates/index.html**: Web interface with environment-based theming
- **Dockerfile**: Container configuration with proper health check setup

### Kubernetes (`k8s/`)

- **namespace.yaml**: Resource isolation for demo components
- **deployment-blue.yaml**: Active deployment (2 replicas, blue theme)
- **deployment-green.yaml**: Standby deployment (0 replicas, green theme)
- **service.yaml**: Traffic routing based on version labels

### Controllers (`controllers/`)

- **failover-controller.yaml**: Complete autonomous controller with RBAC, monitoring logic, and event generation

### Kagent (`kagent/`)

- **modelconfig.yaml**: Claude AI integration and API key management
- **mcpserver.yaml**: Kubernetes tool access via Model Context Protocol
- **memory.yaml**: Persistent context for operational sessions
- **agent.yaml**: Basic agent configuration
- **failover-agent-config.yaml**: Comprehensive agent with blue/green expertise

### Scripts (`scripts/`)

- **setup-sre-companion.sh**: Complete environment deployment with validation
- **load-test.sh**: Controlled load generation for scaling demonstrations
- **cleanup.sh**: Complete environment teardown

## Demo Scenarios

### Autonomous Failover Testing

```bash
# Trigger failover by scaling down blue
kubectl scale deployment web-blue --replicas=0 -n sre-companion-demo

# Monitor controller response
kubectl logs deployment/failover-controller -n sre-companion-demo -f

# Verify automatic traffic switching
kubectl get service web -n sre-companion-demo -o yaml | grep -A 3 selector
```

### Load Testing

```bash
# Generate controlled load
./scripts/load-test.sh 120 150 500

# Test CPU burn endpoint
curl http://localhost:8082/work?ms=500
```

### AI-Powered Operations

Access Kagent dashboard for conversational cluster operations:

- **Cluster Analysis**: "Show me the current state of my blue/green deployment"
- **Log Investigation**: "Are there any issues with my application pods?"
- **Scaling Guidance**: "What scaling approach should I use for increased traffic?"
- **Failover Testing**: "Test my blue/green failover capability"
- **Performance Optimization**: "How can I improve deployment reliability?"

## SRE Principles

### Observability Enhancement

Kagent transforms monitoring data into actionable insights by correlating metrics across systems, identifying patterns, and suggesting proactive measures. This makes complex monitoring accessible to team members regardless of Prometheus or Grafana expertise.

### Reliability Automation

The failover controller demonstrates intelligent automation that maintains service reliability without human intervention. By continuously monitoring and automatically switching traffic during failures, it reduces MTTR and eliminates human error during incidents.

### Operational Knowledge Sharing

Kagent serves as an operational knowledge repository, democratizing expertise across team members with different experience levels. This ensures consistent operational practices regardless of who responds to incidents.

### Progressive Delivery Intelligence

AI-driven blue/green deployment management enables safer deployment practices. Kagent analyzes deployment readiness, suggests rollback criteria, and guides teams through complex scenarios.

### Resilience Validation

Load testing combined with AI analysis validates system resilience. Kagent suggests test scenarios, analyzes results, and recommends improvements, making chaos engineering practices more accessible.

## Validation Commands

### System Health

```bash
# Verify all components
kubectl get pods --all-namespaces

# Check application status
kubectl get pods -n sre-companion-demo
kubectl get deployments -n sre-companion-demo

# Validate Kagent platform
kubectl get pods -n kagent
kubectl get agents -n kagent
```

### Controller Monitoring

```bash
# Failover controller logs
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=20

# Service routing verification
kubectl get endpoints web -n sre-companion-demo
kubectl describe service web -n sre-companion-demo
```

### Application Testing

```bash
# Health check endpoints
curl http://localhost:8082/healthz
curl http://localhost:8082/readyz

# Load generation endpoint
curl http://localhost:8082/work?ms=200
```

## Troubleshooting

### Common Issues

**API Key Problems**: Verify `ANTHROPIC_API_KEY` is exported and has sufficient credits.

**Resource Constraints**: Check Minikube allocation with `minikube config view`. Increase if pods remain pending.

**Image Pull Issues**: Ensure Docker image is built and loaded into Minikube:

```bash
docker build -t resilience-demo:1.1 .
minikube image load resilience-demo:1.1
```

**Agent Configuration Errors**: Verify kagent-anthropic secret exists:

```bash
kubectl get secrets -n kagent | grep anthropic
kubectl create secret generic kagent-anthropic -n kagent \
--from-literal=ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}"
```

### Recovery Procedures

```bash
# Complete environment reset
./scripts/cleanup.sh
./scripts/setup-sre-companion.sh

# Verify recovery
kubectl get pods --all-namespaces
```

### Port Conflicts

```bash
# Use alternative ports for access
kubectl -n sre-companion-demo port-forward service/web 8082:80
kubectl -n kagent port-forward service/kagent-ui 8081:80
```

![Kubernetes SRE AI-Powered](https://img.shields.io/badge/Kubernetes-SRE%20AI--Powered-blue)