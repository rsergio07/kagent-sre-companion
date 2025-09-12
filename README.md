# SRE Companion Demo: AI-Powered Operations with Kagent

This repository demonstrates how Kagent transforms traditional Site Reliability Engineering practices through AI-powered cluster operations. The demo showcases intelligent blue/green deployment management, autonomous failover capabilities, and conversational cluster operations using Claude AI.

Kagent enhances traditional SRE tools by providing intelligent operational insights, automated decision-making, and conversational interfaces that make complex cluster operations accessible to both experienced operators and teams new to Kubernetes.

## Table of Contents

1. [Quick Deployment](#quick-deployment)
2. [Architecture Overview](#architecture-overview)
3. [Configuration Files](#configuration-files)
4. [Load Testing Scenarios](#load-testing-scenarios)
5. [Interactive Demo Framework](#interactive-demo-framework)
6. [AI-Powered Operations](#ai-powered-operations)
7. [SRE Principles](#sre-principles)
8. [Validation Commands](#validation-commands)
9. [Troubleshooting](#troubleshooting)

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

# Grafana monitoring dashboard
kubectl -n monitoring port-forward service/prom-stack-grafana 3000:80
# Visit: http://localhost:3000 (admin/password from secret)
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

## Load Testing Scenarios

The load test script provides controlled traffic generation to demonstrate various operational scenarios. Understanding these patterns helps illustrate different aspects of system behavior under stress.

### Basic Usage Examples

```bash
# Default baseline test (120s duration, 150 concurrency, 500ms CPU burn)
./scripts/load-test.sh
```
**Educational Context**: Establishes baseline metrics for normal operational conditions. This creates steady CPU and memory usage patterns that populate monitoring dashboards with realistic data.

```bash
# Light monitoring load (60 seconds, 25 concurrent requests, 200ms processing)
./scripts/load-test.sh 60 25 200
```
**Educational Context**: Generates minimal system stress suitable for observing normal application behavior. Useful for validating monitoring systems without overwhelming resources.

```bash
# Heavy stress test (300 seconds, 200 concurrent, 1000ms processing)
./scripts/load-test.sh 300 200 1000
```
**Educational Context**: Creates sustained high load that would trigger horizontal pod autoscaling in production environments. Demonstrates how systems respond to prolonged stress conditions.

### Demo-Specific Scenarios

#### Baseline Metrics Generation
```bash
# Gentle background load for dashboard population
./scripts/load-test.sh 600 20 300
```
**Purpose**: Establishes consistent background activity that generates meaningful time-series data in Grafana dashboards. This low-intensity load creates realistic operational patterns without system stress.

**SRE Context**: In production environments, baseline traffic helps establish normal operating ranges for alerting thresholds and capacity planning decisions.

#### Traffic Spike Simulation
```bash
# Sudden traffic increase simulation
./scripts/load-test.sh 120 300 800
```
**Purpose**: Simulates real-world traffic spikes like Black Friday events or viral content scenarios. This pattern tests how quickly the system can adapt to increased demand.

**SRE Context**: Validates horizontal pod autoscaler configuration and helps identify resource bottlenecks before they impact users in production scenarios.

#### Sustained Load Testing
```bash
# Extended moderate load for failover testing
./scripts/load-test.sh 240 100 400
```
**Purpose**: Creates consistent load while testing blue/green failover capabilities. The moderate intensity ensures system remains responsive during failover operations.

**SRE Context**: Demonstrates zero-downtime deployment practices and validates that failover mechanisms work correctly under realistic traffic conditions.

#### Performance Threshold Testing
```bash
# Brief intense burst to identify breaking points
./scripts/load-test.sh 60 500 1200
```
**Purpose**: Identifies system limitations and resource exhaustion points. This aggressive pattern helps understand maximum capacity before performance degradation.

**SRE Context**: Establishes capacity limits for incident response planning and helps define when emergency scaling procedures should be triggered.

#### Gradual Ramp-Up Testing
```bash
# Progressive load increase
./scripts/load-test.sh 180 50 300   # Start gentle
./scripts/load-test.sh 180 100 500  # Increase intensity  
./scripts/load-test.sh 180 200 700  # Peak load
```
**Purpose**: Mimics natural traffic growth patterns and tests how monitoring systems detect gradual changes versus sudden spikes.

**SRE Context**: Validates that alerting systems can distinguish between normal growth and abnormal traffic patterns, reducing false positive alerts.

## Interactive Demo Framework

This five-phase framework demonstrates the progression from manual operations to AI-assisted SRE practices.

### Phase 1: Establish Cluster Awareness

**Objective**: Demonstrate how AI can synthesize complex cluster state into understandable summaries.

**Manual Verification**:
```bash
kubectl get pods -n sre-companion-demo
kubectl get svc -n sre-companion-demo
kubectl top pods -n sre-companion-demo
```

**AI Interaction Examples**:
- "What is the current state of my blue/green deployment?"
- "Which deployment is serving traffic right now?"
- "Show me the pods that are unhealthy or restarting."
- "Summarize the current resource usage in the sre-companion-demo namespace."

**Educational Value**: Shows how AI can eliminate the need to run multiple kubectl commands and correlate information manually.

### Phase 2: Autonomous Failover Scenario

**Objective**: Demonstrate intelligent automation responding to infrastructure failures.

**Trigger Commands**:
```bash
# Force blue deployment failure to trigger automatic failover
kubectl scale deployment web-blue --replicas=0 -n sre-companion-demo

# Monitor failover controller response
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=20
```

**AI Analysis Prompts**:
- "Did a failover event occur just now? Show me the details."
- "How long did it take for traffic to switch to the green deployment?"
- "Which events were recorded by the failover controller?"

**Educational Value**: Illustrates how AI can analyze log data and provide context about automated system responses.

### Phase 3: Load Testing and Scaling

**Objective**: Show how AI interprets system behavior under stress conditions.

**Load Generation**:
```bash
# Generate significant load to trigger scaling behaviors
./scripts/load-test.sh 180 200 600
```

**AI Monitoring Prompts**:
- "Is my application under load right now?"
- "How are the deployment pods performing under stress?"
- "Did any pods restart during this load test?"
- "Summarize error rates and latency during the last 10 minutes."

**Educational Value**: Demonstrates how AI can interpret performance metrics and provide real-time operational insights.

### Phase 4: Root Cause Analysis

**Objective**: Show AI's ability to correlate events and identify patterns across multiple system components.

**Analysis Commands**:
```bash
kubectl logs deployment/failover-controller -n sre-companion-demo | tail -50
kubectl get events -n sre-companion-demo --sort-by=.lastTimestamp | tail -20
```

**AI Investigation Prompts**:
- "Analyze the last failover logs and explain the root cause."
- "Why did my pods restart during the last load test?"
- "Correlate failover-controller events with CPU and memory metrics."
- "Summarize patterns from the last three failure events."

**Educational Value**: Shows how AI can synthesize information from multiple sources to provide comprehensive incident analysis.

### Phase 5: Strategic Recommendations

**Objective**: Demonstrate AI's ability to translate operational data into actionable strategic improvements.

**Optimization Prompts**:
- "Suggest changes to improve the resilience of my blue/green strategy."
- "How can I reduce failover time?"
- "What improvements can I make to resource requests and limits?"
- "Recommend better liveness and readiness probe configurations."
- "What are the top three risks to reliability in my current setup?"

**Educational Value**: Illustrates how AI can provide strategic guidance based on observed operational patterns.

## AI-Powered Operations

Access Kagent dashboard for conversational cluster operations that demonstrate the evolution from command-line tools to natural language interfaces.

### Cluster Analysis Capabilities

**Infrastructure Assessment**: Ask Kagent to analyze deployment configurations, resource allocation, and scaling policies to identify optimization opportunities.

**Performance Monitoring**: Request real-time analysis of CPU utilization, memory consumption, and network traffic patterns across all cluster components.

**Health Diagnostics**: Have the AI examine pod states, service connectivity, and controller logs to identify potential issues before they impact users.

### Operational Automation

**Configuration Management**: Direct Kagent to create, modify, or validate Kubernetes resources through conversational commands rather than YAML manipulation.

**Scaling Decisions**: Ask for intelligent scaling recommendations based on current load patterns, resource utilization, and historical performance data.

**Incident Response**: Use AI-guided troubleshooting that correlates symptoms across multiple system components to accelerate problem resolution.

## SRE Principles

### Observability Enhancement

Kagent transforms monitoring data into actionable insights by correlating metrics across systems, identifying patterns, and suggesting proactive measures. This makes complex monitoring accessible to team members regardless of Prometheus or Grafana expertise.

**Traditional Approach**: Teams manually query Prometheus, interpret Grafana dashboards, and correlate information across multiple tools.

**AI-Enhanced Approach**: Natural language queries that automatically synthesize data from multiple sources and provide contextual recommendations.

### Reliability Automation

The failover controller demonstrates intelligent automation that maintains service reliability without human intervention. By continuously monitoring and automatically switching traffic during failures, it reduces MTTR and eliminates human error during incidents.

**Educational Context**: Shows how modern SRE practices move beyond reactive incident response to proactive automated remediation.

### Operational Knowledge Sharing

Kagent serves as an operational knowledge repository, democratizing expertise across team members with different experience levels. This ensures consistent operational practices regardless of who responds to incidents.

**Scaling Challenge**: Traditional SRE knowledge often resides with senior engineers, creating bottlenecks during incidents or team growth.

**AI Solution**: Conversational access to operational best practices and system-specific guidance that scales expertise across the entire team.

### Progressive Delivery Intelligence

AI-driven blue/green deployment management enables safer deployment practices. Kagent analyzes deployment readiness, suggests rollback criteria, and guides teams through complex scenarios.

**Risk Reduction**: Automated analysis of deployment health metrics and intelligent decision-making about traffic switching reduces the risk of failed deployments.

### Resilience Validation

Load testing combined with AI analysis validates system resilience. Kagent suggests test scenarios, analyzes results, and recommends improvements, making chaos engineering practices more accessible.

**Democratizing Chaos Engineering**: Makes advanced resilience testing practices accessible to teams without specialized chaos engineering expertise.

## Validation Commands

### Cluster Status Commands

#### Overall Cluster Health
```bash
# Complete cluster overview
kubectl get pods --all-namespaces

# Condensed status with key metrics
kubectl get nodes,pods,svc,deployments --all-namespaces
```

#### Agent Pods Only
```bash
# Show just Kagent agent pods
kubectl get pods -n kagent -l app=kagent

# Detailed agent status with ready state
kubectl get pods -n kagent -o wide
```

#### Blue/Green Deployments Only
```bash
# Show both blue and green deployments
kubectl get deployments -n sre-companion-demo -l app=web

# Include replica counts and status
kubectl get deployments,pods -n sre-companion-demo -l app=web
```

### Live Monitoring Commands

#### Watch Pods During Recreation
```bash
# Live pod status updates (Ctrl+C to exit)
kubectl get pods -n sre-companion-demo -w

# Watch with timestamps
kubectl get pods -n sre-companion-demo -w --show-labels
```

#### Monitor Specific Deployment Changes
```bash
# Watch blue deployment scaling events
kubectl get pods -n sre-companion-demo -l version=blue -w

# Watch both blue and green simultaneously
kubectl get pods -n sre-companion-demo -l app=web -w
```

#### Real-time Events Stream
```bash
# Watch cluster events as they happen
kubectl get events -n sre-companion-demo -w

# All events across cluster
kubectl get events --all-namespaces -w
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

### Access Points Reference

#### Grafana
```bash
export POD_NAME=$(kubectl -n monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prom-stack" -o jsonpath="{.items[0].metadata.name}")
kubectl -n monitoring port-forward $POD_NAME 3000
```
Access at [http://localhost:3000](http://localhost:3000)

#### Prometheus
```bash
kubectl -n monitoring port-forward svc/prom-stack-kube-prometheus-prometheus 9090:9090
```
Access at [http://localhost:9090](http://localhost:9090)

#### Kagent UI
```bash
kubectl -n kagent port-forward service/kagent-ui 8080:80
```
Access at [http://localhost:8080](http://localhost:8080)

#### Your Application
```bash
minikube service web -n sre-companion-demo --url
```
Prints the app URL for browser access.

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
kubectl -n monitoring port-forward service/prom-stack-grafana 3000:80
```

![Kubernetes SRE AI-Powered](https://img.shields.io/badge/Kubernetes-SRE%20AI--Powered-blue)