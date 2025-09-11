# SRE Companion Demo: AI-Powered Operations with Kagent

This repository demonstrates how **Kagent** transforms traditional Site Reliability Engineering (SRE) practices through AI-powered cluster operations. The demo showcases intelligent blue/green deployment management, autonomous failover capabilities, and conversational cluster operations using Claude AI.

The project serves two purposes: first, as a **deployable educational environment** where you can explore AI-driven SRE practices in your own Kubernetes cluster, and second, as a **live demonstration platform** showing how Kagent enables natural language interactions with complex operational scenarios.

Rather than replacing traditional SRE tools, Kagent enhances them by providing intelligent operational insights, automated decision-making, and conversational interfaces that make complex cluster operations accessible to both experienced operators and teams new to Kubernetes.

## Table of Contents



## Quick Deployment

For immediate deployment, ensure you have the prerequisites and your Anthropic API key ready:

```bash
# Prerequisites: kubectl, helm, minikube, docker
export ANTHROPIC_API_KEY='your-api-key-here'
```

```bash
# Fork the repository - better comment here
https://github.com/rsergio07/kagent-sre-companion
```

```bash
# Nice comment here to navigate to the repo
cd sre-companion-demo
```

```bash
# nice comment here
./scripts/setup-sre-companion.sh
```

This single script deploys the complete environment including Kubernetes infrastructure, AI integration, and autonomous controllers. The setup process takes approximately 10-15 minutes depending on your cluster resources and network connectivity.

### Core Infrastructure Deployment

Deploy the fundamental Kubernetes components that establish the blue/green deployment pattern:

```bash
# Create namespace and core resources
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment-blue.yaml
kubectl apply -f k8s/deployment-green.yaml
kubectl apply -f k8s/service.yaml
```

These commands create the demonstration namespace and establish the blue/green deployment architecture. The blue deployment starts with 2 replicas as the active environment, while green maintains 0 replicas in standby mode. The service initially routes traffic to blue pods based on label selectors.

### Monitoring Stack Installation

Install Prometheus for comprehensive observability, which provides the data foundation for AI-driven operational decisions:

```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus stack
helm install prom-stack prometheus-community/kube-prometheus-stack \
--namespace monitoring --create-namespace \
-f kagent/monitoring/values.yaml
```

This monitoring installation includes Prometheus for metrics collection, Grafana for visualization, and AlertManager for notification management. The configuration file ensures proper integration with Kagent's observability features.

### Kagent Platform Integration

Deploy the AI-powered operational platform that enables intelligent cluster management:

```bash
# Install Kagent CRDs (Custom Resource Definitions)
helm install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
--version 0.5.5 --namespace kagent --create-namespace --wait

# Install core Kagent components
helm install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
--version 0.5.5 --namespace kagent \
--set providers.anthropic.apiKey="${ANTHROPIC_API_KEY}" \
--wait --timeout=10m
```

The CRDs define custom Kubernetes resources that Kagent uses to manage AI agents, model configurations, and operational sessions. The core installation establishes the platform infrastructure and integrates with your Anthropic API key for AI functionality.

### Agent Configuration

Apply the specific configurations that define how the AI agent interacts with your cluster:

```bash
# Deploy agent configurations
kubectl apply -f kagent/modelconfig.yaml
kubectl apply -f kagent/mcpserver.yaml
kubectl apply -f kagent/memory.yaml
kubectl apply -f kagent/agent.yaml
kubectl apply -f kagent/failover-agent-config.yaml
```

These configurations establish the AI agent's capabilities, including access to Kubernetes APIs, memory management for operational context, and specialized skills for blue/green deployment management.

### Autonomous Controllers

Deploy the intelligent controllers that enable self-healing and automated operational responses:

```bash
# Deploy failover controller
kubectl apply -f controllers/failover-controller.yaml

# Verify deployment
kubectl wait --for=condition=available --timeout=120s deployment/failover-controller -n sre-companion-demo
```

The failover controller continuously monitors service health and automatically switches traffic between blue and green deployments when failures are detected. This demonstrates autonomous operational responses that reduce manual intervention during incidents.

## Configuration Files Overview

### Application Layer (`app/`)

**Purpose**: Provides a simple web application that visually demonstrates blue/green deployment states.

- `app.py`: Flask application with health endpoints (`/healthz`, `/readyz`) and load testing capability (`/work`)
- `requirements.txt`: Python dependencies for the web application
- `templates/index.html`: Web interface that changes color based on deployment environment
- `Dockerfile`: Container configuration optimized for demonstration scenarios

The application design emphasizes observability with proper health check endpoints and the ability to generate controlled load for testing scaling behaviors.

### Kubernetes Layer (`k8s/`)

**Purpose**: Establishes the blue/green deployment pattern with proper service routing.

- `namespace.yaml`: Isolates demo resources from other cluster workloads
- `deployment-blue.yaml`: Active deployment with 2 replicas and blue theming
- `deployment-green.yaml`: Standby deployment with 0 replicas and green theming
- `service.yaml`: Routes traffic based on version labels, initially pointing to blue

This configuration demonstrates fundamental SRE practices including namespace isolation, resource management, and traffic routing strategies for zero-downtime deployments.

### Controllers Layer (`controllers/`)

**Purpose**: Implements autonomous operational logic for failover scenarios.

- `failover-controller.yaml`: Complete controller deployment including RBAC, monitoring logic, and event generation

The controller embodies SRE automation principles by continuously monitoring system health and taking corrective actions without human intervention. It creates Kubernetes events for audit trails and operational transparency.

### Kagent Layer (`kagent/`)

**Purpose**: Configures AI-powered operational capabilities and integrations.

- `agent.yaml`: Basic agent configuration for failover testing
- `failover-agent-config.yaml`: Comprehensive agent with blue/green expertise and deployment strategy guidance
- `modelconfig.yaml`: Claude AI integration settings and API key management
- `mcpserver.yaml`: Model Context Protocol server for Kubernetes tool access
- `memory.yaml`: Persistent context management for operational sessions
- `session.yaml`: Interactive session configuration for live demonstrations

These configurations enable conversational cluster operations where operators can ask questions in natural language and receive intelligent responses based on current cluster state.

### Scripts Layer (`scripts/`)

**Purpose**: Automates deployment processes and provides operational tools for reproducible demonstrations.

- `setup-sre-companion.sh`: Complete environment deployment with validation
- `load-test.sh`: Controlled load generation for scaling demonstrations
- `cleanup.sh`: Complete environment teardown

Script-based automation ensures consistent deployments across different environments and reduces the likelihood of configuration errors during demonstrations.

## Interactive Demo Scenarios

During live demonstrations, we focus on interactive exploration rather than redeployment. The following scenarios showcase Kagent's operational capabilities:

### Cluster State Analysis

**Scenario**: "Show me the current state of my blue/green deployment"

Kagent analyzes pod status, resource utilization, and traffic routing to provide comprehensive deployment insights. This demonstrates how AI can synthesize complex cluster information into actionable operational understanding.

### Intelligent Log Analysis

**Scenario**: "Are there any issues with my application pods?"

The AI agent examines pod logs, events, and metrics to identify potential problems and suggest remediation steps. This showcases proactive problem identification before issues escalate to user-facing failures.

### Scaling Strategy Guidance

**Scenario**: "My application is receiving more traffic. What scaling approach should I use?"

Kagent evaluates current resource utilization, traffic patterns, and application characteristics to recommend appropriate scaling strategies, whether horizontal pod autoscaling, vertical scaling, or deployment pattern changes.

### Failover Testing

**Scenario**: "Test my blue/green failover capability"

The AI agent simulates failure conditions and validates that the autonomous failover controller properly switches traffic between deployments. This demonstrates both testing automation and resilience validation.

### Performance Optimization

**Scenario**: "How can I improve my deployment reliability?"

Kagent analyzes resource requests, limits, probe configurations, and deployment patterns to suggest specific improvements for enhanced reliability and performance.

### Incident Response Simulation

**Scenario**: "Walk me through responding to a pod crash loop"

The AI agent guides operators through systematic incident response procedures while demonstrating how intelligent automation can accelerate problem resolution.

## Why This Matters for SRE

### Observability Enhancement

Traditional monitoring provides data, but Kagent transforms that data into actionable insights. The AI agent can correlate metrics across different systems, identify patterns that might not be obvious to human operators, and suggest proactive measures based on historical trends.

**SRE Connection**: This addresses the observability pillar by making complex monitoring data accessible and actionable, even for team members who may not be expert in reading Prometheus queries or Grafana dashboards.

### Reliability Automation

The failover controller demonstrates how intelligent automation can maintain service reliability without human intervention. By continuously monitoring service health and automatically switching traffic during failures, the system embodies the SRE principle of automating toil.

**SRE Connection**: This directly supports reliability objectives by reducing mean time to recovery (MTTR) and eliminating human error during incident response procedures.

### Operational Knowledge Sharing

Kagent serves as a operational knowledge repository that can answer questions about deployment strategies, scaling approaches, and troubleshooting procedures. This democratizes operational expertise across team members with different experience levels.

**SRE Connection**: This addresses the SRE challenge of scaling operational knowledge across growing teams and ensures consistent operational practices regardless of who is responding to incidents.

### Progressive Delivery Intelligence

The blue/green deployment pattern, enhanced with AI-driven decision making, demonstrates how teams can implement safer deployment practices. Kagent can analyze deployment readiness, suggest rollback criteria, and guide teams through complex deployment scenarios.

**SRE Connection**: This supports the SRE emphasis on reducing the risk of change through intelligent deployment strategies and automated safety mechanisms.

### Resilience Validation

The load testing capabilities combined with AI analysis enable teams to validate system resilience under various conditions. Kagent can suggest specific test scenarios, analyze results, and recommend improvements based on observed behavior.

**SRE Connection**: This supports the SRE practice of chaos engineering and resilience testing by making these practices more accessible and providing intelligent interpretation of test results.

## Expected Outcomes

### For Repository Users

**Technical Understanding**: Gain hands-on experience with blue/green deployments, Kubernetes controllers, and AI-powered operational tools. Understand how different components integrate to create a comprehensive operational platform.

**Operational Skills**: Learn to implement autonomous failover mechanisms, configure intelligent monitoring, and integrate AI capabilities into existing operational workflows.

**Architecture Insights**: Understand how traditional SRE practices can be enhanced with AI without replacing fundamental operational principles or existing tooling investments.

### For Demo Participants

**AI Integration Clarity**: See concrete examples of how AI can enhance rather than replace traditional operational practices. Understand the practical applications of conversational cluster operations.

**Operational Efficiency**: Observe how AI-powered tools can accelerate common operational tasks like troubleshooting, scaling decisions, and incident response procedures.

**Strategic Understanding**: Gain insights into how AI can democratize operational expertise and enable teams to implement more sophisticated operational practices regardless of their current expertise level.

### For Everyone

**SRE Evolution**: Understand how Site Reliability Engineering practices are evolving to incorporate AI capabilities while maintaining focus on fundamental reliability principles.

**Practical Implementation**: See realistic examples of AI integration that teams can adapt to their specific operational requirements and existing tool ecosystems.

**Future Readiness**: Gain familiarity with emerging operational patterns that combine traditional SRE practices with intelligent automation and AI-driven decision making.

## Troubleshooting

### Common Issues

**Anthropic API Key Problems**: Ensure your API key is valid and properly exported. The key must have sufficient credits for Claude API usage.

**Resource Constraints**: If pods remain in pending state, verify that your Minikube cluster has adequate CPU and memory allocation. Increase resources if necessary.

**Network Connectivity**: Some installations require internet access for Helm charts and container images. Ensure your environment can reach external repositories.

**RBAC Permissions**: If controllers fail to start, verify that RBAC configurations are properly applied and that service accounts have necessary permissions.

### Validation Commands

```bash
# Verify core deployment
kubectl get pods -n sre-companion-demo

# Check Kagent platform
kubectl get pods -n kagent

# Validate controller logs
kubectl logs deployment/failover-controller -n sre-companion-demo

# Test application access
minikube service web -n sre-companion-demo --url
```

### Recovery Procedures

If the environment becomes unstable, use the cleanup script to reset:

```bash
./scripts/cleanup.sh
```

Then redeploy using the setup script. This approach ensures a clean environment for subsequent demonstrations or learning sessions.
The demonstration environment is designed to be ephemeral and easily reproducible, supporting iterative learning and experimentation with different configuration options.

![Kubernetes SRE AI-Powered](https://img.shields.io/badge/Kubernetes-SRE%20AI--Powered-blue)