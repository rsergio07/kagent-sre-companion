# SRE Companion Demo: Dual-Provider AI-Powered Operations with Kagent

This repository demonstrates how **Kagent** transforms traditional Site Reliability Engineering (SRE) practices through **dual-provider AI-powered cluster operations**. The demo showcases intelligent blue/green deployment management, autonomous failover capabilities, conversational cluster operations with dual AI providers (OpenAI GPT-4o and Anthropic Claude Sonnet 4), and comprehensive monitoring integration.

Rather than showcasing perfect workflows, this demo deliberately exposes real-world challenges — incomplete metrics, rate limits, and service misconfigurations — transforming them into valuable learning opportunities for modern SRE practices.

---

## **Quick Start**

### **Prerequisites**

- Docker, Kubernetes (kubectl), Helm, and Minikube
- Minimum: 8 CPU cores, 16GB RAM, 40GB disk space
- API Keys: `ANTHROPIC_API_KEY` and `OPENAI_API_KEY`

### **Complete Environment Deployment**

Anthropic: https://console.anthropic.com/
OpenAI: https://platform.openai.com/

```bash
# Required: Set your AI provider API keys before deployment
export ANTHROPIC_API_KEY="your-anthropic-key-here"
export OPENAI_API_KEY="your-openai-key-here"
```

```bash
# Complete SRE Companion Demo environment deployment
./scripts/setup-sre-companion.sh

# The script will perform comprehensive environment provisioning:
# - Force cleanup of existing Minikube/Docker states
# - Fresh Minikube cluster with adequate resources (6 CPU, 12GB RAM)
# - Demo application build and image loading
# - Core blue/green deployment infrastructure
# - Prometheus monitoring stack with custom configurations
# - Kagent platform with dual AI provider setup (OpenAI + Anthropic)
# - 11 specialized AI agents for collaborative operations
# - Autonomous failover controller deployment
# - Automatic port forwarding and browser launching
```

### **Access Points**

- **Demo Application:** http://localhost:8082
- **Kagent AI Dashboard:** http://localhost:8081
- **Grafana Monitoring:** http://localhost:3000
- **Prometheus:** http://localhost:9090

---

## Pre-Demo Environment Preparation

### Continuous Metrics Generation for Realistic Scenarios

For presentation or training scenarios requiring rich operational history, use the continuous metrics generator to populate your environment with authentic SRE data patterns.

#### When to Use This Script

**Scenario:** You need realistic operational data for demonstrations, training sessions, or testing AI agent responses to complex scenarios.

**Timing for Presentations:**
- **4+ hour talks:** Start script 4-5 hours before presentation
- **Live demos:** Start 2-3 hours before to have fresh events (Kubernetes events expire after ~1 hour)
- **Training sessions:** Run overnight before multi-day workshops

#### Script Usage

```bash
# Start continuous realistic load generation
./scripts/continuous-metrics-generator.sh

# The script will run 100 cycles of varied operational patterns:
# - Light sustained load with scaling events
# - Memory pressure spikes  
# - Restart avalanches under load
# - Rapid scaling with burst traffic
# - Maximum chaos scenarios combining all patterns
```

#### Expected Outcomes

After running this script, your environment will show:
- **Rich Grafana dashboard data** with realistic resource usage patterns
- **Failover controller logs** showing actual decision-making under pressure
- **Pod restart and scaling events** demonstrating Kubernetes self-healing
- **Correlated metrics** across memory, CPU, and availability dimensions
- **Authentic operational complexity** for AI agent analysis

#### Validation Commands

```bash
# Verify rich operational data is available
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=20
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | head -10
kubectl top pods -n sre-companion-demo
```

---

## **Architecture Overview**

### **AI Operations Ecosystem**

This demo deploys a **complete AI operations ecosystem** consisting of **11 specialized agents** that work collaboratively across different operational domains:

**Infrastructure Management:**

- `k8s-agent` - Core Kubernetes operations and troubleshooting
- `helm-agent` - Package management and chart operations
- `observability-agent` - Prometheus, Grafana, and monitoring

**Network and Service Mesh:**

- `cilium-debug-agent` - Network debugging and diagnostics
- `cilium-manager-agent` - CNI management and configuration
- `cilium-policy-agent` - Network policy creation and management
- `istio-agent` - Service mesh operations and maintenance
- `kgateway-agent` - API gateway operations

**Deployment and DevOps:**

- `argo-rollouts-conversion-agent` - Progressive delivery patterns
- `promql-agent` - Natural language to PromQL generation
- `sre-companion` - Custom blue/green deployment specialist

### **Dual-Provider AI Framework**

- **OpenAI GPT-4o:** Rapid operational responses, immediate actions, fast incident triage
- **Anthropic Claude Sonnet 4:** Deep analytical reasoning, strategic planning, comprehensive analysis
- **Real-time switching** between providers through Kagent UI for comparative analysis

---

## **Repository Structure**

### **Application Layer (`app/`)**

**`app.py`** - Flask demonstration application serving as the target workload for SRE operations
- **Root endpoint (`/`):** Dynamic interface reflecting deployment version with color-coded theming
- **Health endpoints (`/healthz`, `/readyz`):** Kubernetes-compliant liveness and readiness probes
- **Work endpoint (`/work`):** Configurable CPU burn functionality for load testing demonstrations

**`requirements.txt`** - Minimal production dependencies (Flask, Gunicorn) for security and simplicity

**`templates/index.html`** - Responsive web interface with environment-driven theming for immediate visual feedback during blue/green transitions

### **Kubernetes Manifests (`k8s/`)**

**`namespace.yaml`** - Isolated demo environment within `sre-companion-demo` namespace

**`deployment-blue.yaml`** - Primary active deployment (2 replicas) with comprehensive resource limits and health probe configuration

**`deployment-green.yaml`** - Standby deployment (0 replicas) for blue/green pattern demonstration

**`service.yaml`** - NodePort service with version-specific selectors enabling traffic routing between deployments

### **Autonomous Operations (`controllers/`)**

**`failover-controller.yaml`** - Sophisticated autonomous failover system implementing modern SRE automation
- **ServiceAccount & RBAC:** Granular permissions for safe cluster operations
- **ConfigMap:** Python-based monitoring logic with endpoint health evaluation
- **Deployment:** High-availability control plane with automatic traffic switching capabilities
- **Event Generation:** Kubernetes events for audit trails and observability integration

### **AI Platform Integration (`kagent/`)**

**`agent.yaml`** - Custom SRE agent specialized in blue/green deployment operations with comprehensive Kubernetes tool integration

**`modelconfig-openai.yaml`** & **`modelconfig-anthropic.yaml`** - Dual-provider AI configuration for comparative analysis capabilities

**`memory.yaml`** & **`session.yaml`** - Persistent context and conversation state management across AI provider switches

**`monitoring/values.yaml`** - Prometheus stack customization enhancing AI agent access to metrics and alerting data

### **Monitoring and Observability (`grafana/`)**

**`sre-demo-dashboard.json`** - Comprehensive Grafana dashboard designed for blue/green deployment monitoring

- **Resource Monitoring:** Memory and CPU utilization tracking per pod
- **Deployment Health:** Replica count visualization and restart pattern analysis
- **Correlation Views:** Relationships between resource consumption and application performance
- **AI Integration:** Natural language query support for complex metrics analysis

**### Interactive Operational Scripts (`scripts/`)**

**`setup-sre-companion.sh`** - Comprehensive environment provisioning with dual AI provider setup

- **Prerequisites validation** and Docker runtime management
- **Minikube cluster provisioning** and image loading
- **Complete stack deployment** (application, monitoring, AI platform)
- **Automatic service configuration** and browser launching

**`continuous-metrics-generator.sh`** - Sophisticated chaos engineering and load generation framework

- **Automated load pattern generation:** 5 distinct operational scenarios in rotating cycles
- **Realistic chaos engineering:** Memory pressure spikes, restart avalanches, scaling events
- **Presentation preparation:** 4+ hour runtime populating dashboards with authentic operational data
- **Comprehensive cleanup handling:** Graceful signal management and deployment state restoration

**`load-test.sh`** - Sophisticated load generation framework

- **Configurable parameters:** Duration, concurrency, CPU burn intensity
- **Multiple testing modes:** Baseline, progressive, stress testing
- **Monitoring integration:** Populates dashboards with realistic operational data

**`simulate-failure.sh`** - Controlled chaos engineering framework

- **Immediate failure mode:** Rapid pod deletion for self-healing demonstration
- **Controlled outage mode:** Predictable failure scenarios with automatic recovery
- **Comprehensive logging:** Post-incident analysis and MTTR measurement

**`cleanup.sh`** - Complete environment removal with cluster destruction and artifact cleanup

### **Container Configuration**

**`Dockerfile`** - Production-ready containerization with security best practices

- **Python 3.11 slim base** for minimal attack surface
- **Environment variable configuration** for runtime customization
- **Multi-worker Gunicorn setup** for production serving capabilities

---

## **Key Features and Capabilities**

### **Production-Ready SRE Practices**

- **Blue/Green Deployments:** Live traffic switching with zero-downtime patterns
- **Autonomous Failover:** AI-augmented automation reducing MTTR
- **Chaos Engineering:** Controlled failure injection and recovery testing
- **Comprehensive Monitoring:** Prometheus, Grafana, and custom dashboard integration

### **AI-Powered Operations**

- **Multi-Agent Collaboration:** Specialized agents working across operational domains
- **Comparative AI Analysis:** Direct comparison of reasoning approaches for identical scenarios
- **Natural Language Operations:** Complex Kubernetes operations through conversational interfaces
- **Persistent Context:** Memory and session management across AI provider switches

### **Educational Value**

- **Real-World Scenarios:** Authentic challenges with service misconfigurations and partial failures
- **Hands-On Learning:** Interactive scripts and guided exercises
- **Best Practices Demonstration:** Production patterns in accessible demo format
- **Operational Excellence:** SRE methodologies with modern AI augmentation

---

## **Technology Stack**

### **Core Infrastructure**

- **Kubernetes (Minikube):** Container orchestration and cluster management
- **Prometheus:** Metrics collection and monitoring
- **Grafana:** Visualization and dashboard management
- **Helm:** Package management and application deployment

### **AI Platform**

- **Kagent Framework:** Cloud-native AI agent platform
- **OpenAI GPT-4o:** Rapid operational responses and tool integration
- **Anthropic Claude Sonnet 4:** Advanced reasoning and strategic analysis
- **Model Context Protocol (MCP):** Standardized AI tool integration

### **Application Components**

- **Flask:** Lightweight web application framework
- **Gunicorn:** Production WSGI server
- **Python 3.11:** Runtime environment with security focus

---

## **What Makes This Special**

This isn't just another SRE demo—it's a **comprehensive AI operations research platform** that demonstrates:

- **Multi-agent specialization** across 11 different operational domains
- **Dual-provider AI comparison** showing different reasoning approaches to identical problems
- **Collaborative workflows** between specialized agents using different AI models
- **Real-world operational scenarios** with authentic challenges and learning opportunities
- **Production-ready practices** implemented through modern SRE automation patterns

Whether you're exploring AI-augmented operations, learning about blue/green deployments, or researching comparative AI reasoning in infrastructure management, this platform provides hands-on experience with the future of Site Reliability Engineering.

---

**Ready to explore AI-powered SRE operations? Start with the [Demo Runbook](./Runbook.md)!**

![Kagent SRE Demo](https://img.shields.io/badge/Kagent-SRE%20Demo-purple) ![Dual Provider AI](https://img.shields.io/badge/Dual%20Provider-AI%20Ops-blue) ![Multi Agent](https://img.shields.io/badge/Multi%20Agent-Ecosystem-green)