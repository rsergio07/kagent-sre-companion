# SRE Companion Demo: Dual-Provider AI-Powered Operations with Kagent

This repository demonstrates how **Kagent** transforms traditional Site Reliability Engineering (SRE) practices through **dual-provider AI-powered cluster operations**. Rather than showcasing perfect workflows, this demo deliberately exposes real-world challenges — incomplete metrics, rate limits, and service misconfigurations — transforming them into valuable learning opportunities for modern SRE practices.

The demonstration encompasses intelligent blue/green deployment management, autonomous failover capabilities, conversational cluster operations with dual AI providers (OpenAI GPT-4o and Anthropic Claude Sonnet 4), and seamless integration of monitoring, load testing, and failure simulation into cohesive operational scenarios through **hands-on scripted exercises**.

## Repository Structure and Component Architecture

The project follows a logical separation of concerns designed to showcase production-ready SRE practices while maintaining educational clarity. Each directory serves a specific purpose in the overall demonstration ecosystem.

### Application Layer (`app/`)

The **`app/`** directory contains the demonstration Flask application that serves as the target workload for all SRE operations. The **`app.py`** file implements a lightweight web service with three critical endpoints that mirror real-world application patterns. The root endpoint (`/`) renders a dynamic interface that changes color and metadata based on deployment version, providing immediate visual feedback during failover scenarios. The health endpoints (`/healthz` and `/readyz`) follow Kubernetes best practices for liveness and readiness probes, ensuring proper integration with the orchestration layer. The work endpoint (`/work`) provides configurable CPU burn functionality for load testing and scaling demonstrations.

The **`requirements.txt`** file maintains minimal dependencies (Flask and Gunicorn) to reduce complexity and potential security vulnerabilities while providing production-ready serving capabilities. The **`templates/index.html`** file creates a responsive interface that dynamically reflects the current deployment state through environment-driven theming, making blue/green transitions immediately visible to operators and stakeholders.

### Kubernetes Manifests (`k8s/`)

The **`k8s/`** directory contains the core Kubernetes resources that demonstrate production blue/green deployment patterns. The **`namespace.yaml`** isolates all demo resources within the `sre-companion-demo` namespace, following security and organizational best practices while preventing conflicts with other cluster workloads.

The **`deployment-blue.yaml`** and **`deployment-green.yaml`** files implement identical deployment specifications with environment-specific customizations. The blue deployment starts with 2 replicas and serves as the primary active environment, while the green deployment initializes with 0 replicas in standby mode. Both deployments include comprehensive resource limits and requests to enable proper autoscaling behavior, along with properly configured health probes that integrate with the application endpoints.

The **`service.yaml`** defines a NodePort service with version-specific selectors that enable traffic routing between blue and green deployments. This service configuration serves as the focal point for the autonomous failover controller, which modifies the selector labels to redirect traffic during outage scenarios.

### Autonomous Operations (`controllers/`)

The **`failover-controller.yaml`** implements a sophisticated autonomous failover system that embodies modern SRE automation principles. The controller includes comprehensive RBAC permissions for safe cluster operations, a ConfigMap containing Python-based monitoring logic, and a deployment specification that ensures high availability of the control plane itself.

The embedded monitoring script continuously evaluates service endpoint availability and automatically switches traffic routing when outages are detected. The controller creates Kubernetes events for audit trails and integrates with the broader observability stack through structured logging. This component demonstrates how AI-augmented automation can reduce Mean Time To Recovery (MTTR) while maintaining human oversight capabilities.

### Dual-Provider AI Platform Integration (`kagent/`)

The **`kagent/`** directory contains the complete configuration for dual-provider AI-powered operational capabilities. The **`modelconfig-anthropic.yaml`** establishes connection to Claude Sonnet 4 for advanced reasoning and complex incident analysis, while **`modelconfig-openai.yaml`** configures GPT-4o for rapid operational responses and tool integration.

The **`agent.yaml`** defines a specialized SRE agent with comprehensive knowledge of blue/green deployment patterns, failover scenarios, and Kubernetes operational best practices. The agent can seamlessly switch between AI providers through the Kagent UI, enabling comparative analysis of different AI reasoning approaches for identical operational scenarios.

The **`memory.yaml`** and **`session.yaml`** files enable persistent context and conversation state management, allowing AI agents to maintain awareness of ongoing operations and historical decisions across provider switches. The **`monitoring/values.yaml`** customizes Prometheus stack deployment with demo-specific configurations that enhance AI agent access to metrics and alerting data.

#### Dual-Provider Architecture Benefits

- **OpenAI GPT-4o**: Optimized for rapid operational responses, excellent tool integration, and fast incident triage
- **Anthropic Claude Sonnet 4**: Advanced reasoning capabilities, complex root cause analysis, and strategic planning
- **Comparative Analysis**: Direct comparison of AI reasoning approaches for identical SRE scenarios
- **Provider Switching**: Real-time model switching through the Kagent UI without configuration changes

### Monitoring and Observability (`grafana/`)

The **`sre-demo-dashboard.json`** provides a comprehensive Grafana dashboard specifically designed for blue/green deployment monitoring. The dashboard includes memory and CPU utilization tracking per pod, restart pattern analysis, replica count visualization for both deployment versions, and correlation views that help identify relationships between resource consumption and application performance.

This dashboard integrates seamlessly with AI agent queries, enabling natural language access to complex metrics analysis and trend identification. The visualization design emphasizes operational decision-making rather than just data display, making it valuable for both human operators and AI-powered analysis.

### Interactive Operational Scripts (`scripts/`)

The **`scripts/`** directory contains the core automation tools that make this demo interactive and realistic. These scripts serve as the primary interface for hands-on operational exercises and enable realistic testing scenarios that mirror production operational patterns.

#### **Load Testing Framework (`load-test.sh`)**

The **`load-test.sh`** script provides sophisticated load generation capabilities with configurable parameters for duration, concurrency, and CPU burn intensity. This script serves multiple purposes: populating monitoring dashboards with realistic operational data, triggering autoscaling policies for scaling behavior analysis, validating system performance under various load conditions, and creating baseline metrics for AI-powered analysis.

The script accepts three primary parameters enabling flexible testing scenarios:
- **Duration**: Test execution time (default: 120 seconds)
- **Concurrency**: Simultaneous request threads (default: 150)
- **CPU Burn**: Milliseconds of CPU work per request (default: 500ms)

Advanced usage patterns include progressive load testing for capacity discovery, stress testing for breaking point identification, sustained load testing for endurance validation, and baseline testing for performance regression analysis.

#### **Chaos Engineering Framework (`simulate-failure.sh`)**

The **`simulate-failure.sh`** script implements controlled failure injection with two distinct operational modes. The **immediate failure mode** triggers rapid pod deletion to demonstrate Kubernetes self-healing capabilities and recovery time measurement. The **controlled outage mode** provides predictable failure scenarios with configurable duration and automatic recovery, enabling comprehensive failover testing and Mean Time To Recovery analysis.

The script supports both blue and green deployment targeting, configurable outage duration for predictable testing scenarios, graceful recovery with replica restoration, and comprehensive logging for post-incident analysis. This enables realistic chaos engineering practices without requiring complex external tools or infrastructure modifications.

#### **Environment Management (`setup-sre-companion.sh` and `cleanup.sh`)**

The **`setup-sre-companion.sh`** script provides comprehensive environment provisioning with robust error handling, prerequisite validation, and automated service configuration. The script manages Docker runtime selection, Minikube cluster provisioning, comprehensive component deployment, and automatic service access configuration with dual AI provider setup.

The **`cleanup.sh`** script ensures complete environment removal including cluster destruction, context cleanup, and artifact removal, enabling reliable reset capabilities for repeated demonstrations and configuration testing.

### Container Image (`Dockerfile`)

The **`Dockerfile`** implements security and performance best practices for containerized applications. The multi-stage approach uses Python 3.11 slim base images to minimize attack surface while maintaining compatibility. Environment variable configuration enables dynamic behavior modification without requiring image rebuilds, supporting the blue/green deployment pattern through runtime customization.

## Quick Deployment and Configuration

### Prerequisites and Environment Setup

Successful deployment requires Docker, Kubernetes (kubectl), Helm, and Minikube installed with appropriate system resource allocation. The minimum recommended configuration includes 8 CPU cores, 16GB RAM, and 40GB disk space for complete functionality including AI model operations and comprehensive monitoring.

Configure your dual AI provider API keys through environment variable export to enable AI-powered operational capabilities:

```bash
# Configure dual AI provider access
export ANTHROPIC_API_KEY="your-anthropic-key-here"
export OPENAI_API_KEY="your-openai-key-here"

# Clone and navigate to project
git clone https://github.com/rsergio07/kagent-sre-companion
cd kagent-sre-companion
```

### Complete System Deployment

Execute the comprehensive setup script for full environment provisioning. The automated deployment typically requires 10-15 minutes depending on network conditions and system performance:

```bash
./scripts/setup-sre-companion.sh
```

This process provisions the Flask demonstration application with blue/green configuration, complete monitoring stack including Prometheus and Grafana with custom dashboards, autonomous failover controller with comprehensive permissions and monitoring logic, and the Kagent AI platform with dual-provider agent capabilities and model configurations.

### Service Access and Port Management

The deployment automatically configures port forwarding for all services and launches browser windows for immediate access. Manual port forwarding configuration enables flexible access patterns:

### Access Points

**Application interface (blue/green demonstration)**  

```bash
kubectl -n sre-companion-demo port-forward service/web 8082:80
```

[➡ Open Application](http://localhost:8082)

**Kagent AI dashboard (dual-provider conversational operations)**

```bash
kubectl -n kagent port-forward service/kagent-ui 8081:80
```

[➡ Open Kagent UI](http://localhost:8081)

**Grafana monitoring dashboard (metrics and visualization)**

```bash
kubectl -n monitoring port-forward service/prom-stack-grafana 3000:80
```

[➡ Open Grafana](http://localhost:3000)

**Prometheus monitoring dashboard (raw metrics access)**

```bash
kubectl -n monitoring port-forward svc/prom-stack-kube-prometheus-prometheus 9090:9090
```

[➡ Open Prometheus](http://localhost:9090)

Port conflict resolution may require process termination when ports remain bound after session closure:

```bash
# Identify processes using demo ports
lsof -i :8082 -i :8081 -i :3000 -i :9090

# Terminate specific processes (use with caution)
kill -9 <PID>
```

## Dual-Provider AI Operational Framework

The demonstration leverages both AI providers for complementary capabilities in SRE scenarios. The Kagent UI allows seamless switching between providers to compare reasoning approaches for identical operational challenges.

### Comparative AI Analysis Examples

**OpenAI GPT-4o Queries** (Fast operational responses and tool integration):
- *"What is the current state of my blue/green deployment?"*
- *"Scale the blue deployment to handle traffic spike"*
- *"Show me recent pod restart events and resource utilization"*
- *"Execute immediate failover to green deployment"*

**Anthropic Claude Sonnet 4 Queries** (Deep analytical reasoning and strategic planning):
- *"Analyze the root cause patterns from our recent cascade failure and recommend architectural improvements"*
- *"Design a comprehensive incident response playbook based on observed failure modes"*
- *"Evaluate our current SRE practices against industry reliability standards and suggest optimization strategies"*
- *"Create a 6-month reliability engineering roadmap based on operational patterns we've observed"*

### Provider Selection Strategy

- **Incident Triage**: Use GPT-4o for rapid assessment and immediate response actions
- **Root Cause Analysis**: Switch to Claude Sonnet 4 for comprehensive investigation and strategic recommendations  
- **Performance Optimization**: Compare both providers' recommendations for capacity planning and architectural decisions
- **Documentation**: Leverage Claude Sonnet 4 for detailed incident reports and process documentation

## Multi-Agent AI Operations Ecosystem

### **Comprehensive Agent Portfolio**

This demonstration deploys a **complete AI operations ecosystem** consisting of **11 specialized agents** that work collaboratively across different operational domains. Your custom **`sre-companion`** agent operates alongside **10 default Kagent agents** that provide comprehensive cloud-native operational coverage:

**Infrastructure Management Agents:**
- **`k8s-agent`** - Core Kubernetes cluster operations, troubleshooting, and maintenance
- **`helm-agent`** - Helm package management and chart operations specialist
- **`observability-agent`** - Prometheus, Grafana, and Kubernetes-native monitoring

**Network and Service Mesh Specialists:**
- **`cilium-debug-agent`** - Cilium network debugging and diagnostics
- **`cilium-manager-agent`** - Cilium cluster networking management and configuration
- **`cilium-policy-agent`** - Network policy creation and management
- **`istio-agent`** - Service mesh operations, troubleshooting, and maintenance
- **`kgateway-agent`** - API gateway operations with Envoy proxy expertise

**Advanced Deployment and DevOps Agents:**
- **`argo-rollouts-conversion-agent`** - Kubernetes Deployments to Argo Rollouts conversion
- **`promql-agent`** - Natural language to PromQL query generation
- **`sre-companion`** - Your custom blue/green deployment and SRE operations specialist

### **Platform-Wide Dual-Provider Capabilities**

The dual AI provider configuration (OpenAI GPT-4o and Anthropic Claude Sonnet 4) extends across **all 11 agents**, enabling comprehensive comparative analysis across every operational domain. This creates unprecedented opportunities for **cross-functional AI reasoning comparison**.

## Cross-Domain Comparative Analysis Framework

| **Operational Domain** | **OpenAI GPT-4o Capabilities** | **Anthropic Claude Sonnet 4 Capabilities** |
|---|---|---|
| **Kubernetes Operations** (`k8s-agent`) | • Rapid cluster health assessments • Immediate resource scaling recommendations • Fast troubleshooting workflows for pod scheduling • Quick resolution of resource constraints | • Comprehensive cluster architecture analysis • Long-term capacity planning strategies • Security posture evaluation • Strategic infrastructure optimization roadmaps |
| **Package Management** (`helm-agent`) | • Quick chart installations • Dependency resolution • Immediate upgrade/rollback operations • Fast application deployment workflows | • Strategic chart architecture design • Comprehensive dependency analysis • Security vulnerability assessment • Enterprise-grade deployment planning |
| **Observability Operations** (`observability-agent`) | • Real-time metrics interpretation • Alert triage and immediate response • Dashboard customization for incidents • Fast performance bottleneck identification | • Comprehensive monitoring strategy design • SLI/SLO framework development • Alerting optimization to reduce noise • Observability maturity assessment |
| **Network Debugging** (`cilium-debug-agent`) | • Rapid connectivity diagnosis • Immediate network policy fixes • Fast service-to-service communication resolution • Quick packet flow troubleshooting | • Deep network topology analysis • Comprehensive security policy architecture • Performance optimization strategies • Network resilience planning |
| **Network Management** (`cilium-manager-agent`) | • Quick network configuration changes • Immediate CNI troubleshooting • Fast cluster networking adjustments • Rapid IP address management | • Strategic network architecture design • Comprehensive security boundary planning • Multi-cluster networking strategies • Network performance optimization |
| **Network Policy Operations** (`cilium-policy-agent`) | • Rapid policy creation and validation • Immediate security rule adjustments • Fast compliance remediation • Quick micro-segmentation setup | • Comprehensive security policy frameworks • Zero-trust architecture design • Compliance strategy development • Security posture evolution planning |
| **Service Mesh Operations** (`istio-agent`) | • Quick service mesh troubleshooting • Immediate traffic routing fixes • Fast configuration adjustments • Rapid service connectivity resolution | • Strategic service mesh architecture planning • Comprehensive security policy design • Observability strategy development • Multi-cluster service mesh evolution |
| **API Gateway Management** (`kgateway-agent`) | • Fast gateway configuration • Immediate routing fixes • Rapid API endpoint troubleshooting • Quick traffic management adjustments | • Strategic API gateway architecture design • Comprehensive security boundary planning • Traffic management optimization • Enterprise API strategy development |
| **Progressive Delivery** (`argo-rollouts-conversion-agent`) | • Fast deployment pattern conversions • Immediate rollback procedures • Quick canary/blue-green setup • Rapid deployment troubleshooting | • Strategic progressive delivery architecture • Comprehensive risk assessment frameworks • Deployment automation strategies • Enterprise delivery pipeline optimization |
| **Metrics Query Generation** (`promql-agent`) | • Rapid PromQL query generation • Immediate metrics troubleshooting • Fast dashboard query optimization • Quick alerting rule creation | • Comprehensive metrics strategy design • Advanced alerting query development • Strategic monitoring architecture planning • Observability query optimization frameworks |
| **SRE Operations** (`sre-companion`) | • Fast failover execution • Immediate incident response • Quick blue/green deployment management • Rapid operational scenario handling | • Strategic reliability engineering planning • Comprehensive incident analysis • SRE maturity assessment • Long-term reliability architecture development |

### **Collaborative Multi-Agent Workflows**

The platform enables sophisticated **collaborative scenarios** where multiple agents work together using different AI providers:

- **Incident Response**: Use `k8s-agent` (GPT-4o) for rapid triage, then `observability-agent` (Claude Sonnet 4) for comprehensive analysis
- **Network Troubleshooting**: Combine `cilium-debug-agent` (GPT-4o) for immediate fixes with `cilium-policy-agent` (Claude Sonnet 4) for strategic security improvements
- **Deployment Optimization**: Leverage `argo-rollouts-conversion-agent` (GPT-4o) for quick conversions and `sre-companion` (Claude Sonnet 4) for reliability planning

## Interactive Demonstration Framework

The demonstration progresses through comprehensive phases that showcase dual-provider AI-augmented SRE practices. Each phase combines hands-on script execution with comparative AI analysis to create realistic operational scenarios.

### **Phase 1: Environment Validation and Baseline Assessment**

**Commands to Execute:**
```bash
# Verify multi-agent ecosystem deployment
kubectl get agents -n kagent

# Check blue/green deployment status
kubectl get pods -n sre-companion-demo
kubectl get deployments,services -n sre-companion-demo
```

**Follow-up AI Queries:**
- **Query 1** (Any agent): *"What is the current state of my blue/green deployment? Analyze pod health, service routing, and resource allocation."*
- **Query 2** (Switch providers): *"Are the resource requests and limits appropriately sized for this workload? Provide optimization recommendations."*

### **Phase 2: Load Testing and Performance Analysis**

**Commands to Execute:**
```bash
# Light load baseline testing
./scripts/load-test.sh 60 50 200

# Progressive load testing
./scripts/load-test.sh 120 150 400

# Stress testing with higher concurrency
./scripts/load-test.sh 120 300 700
```

**Follow-up AI Queries:**
- **Query 1** (GPT-4o): *"Analyze the performance metrics from our load tests. What are the current bottlenecks and capacity limits?"*
- **Query 2** (Claude Sonnet 4): *"Compare our performance against SLA requirements and recommend comprehensive scaling strategies based on observed patterns."*

### **Phase 3: Failure Simulation and Recovery Testing**

**Commands to Execute:**
```bash
# Immediate pod failure (self-healing demonstration)
./scripts/simulate-failure.sh blue

# Monitor recovery process
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp' | tail -10

# Controlled outage with predictable timing
./scripts/simulate-failure.sh blue --outage 30
```

**Follow-up AI Queries:**
- **Query 1** (GPT-4o): *"Analyze the failover event timing and recovery process. What was the Mean Time To Recovery?"*
- **Query 2** (Claude Sonnet 4): *"Design resilience improvement strategies based on the failure patterns we observed. Include industry best practices."*

### **Phase 4: Cascading Failure and Complex Scenarios**

**Commands to Execute:**
```bash
# Start sustained load in background
./scripts/load-test.sh 300 200 500 &

# Create cascading failure scenario
sleep 60
./scripts/simulate-failure.sh blue --outage 60

# Secondary failure while blue is recovering
sleep 30
./scripts/simulate-failure.sh green --outage 30
```

**Follow-up AI Queries:**
- **Query 1** (GPT-4o): *"Analyze this cascading failure scenario. How did the system handle multiple simultaneous failures?"*
- **Query 2** (Claude Sonnet 4): *"Design comprehensive chaos engineering strategies based on this behavior. What's our blast radius and how can we implement circuit breakers?"*

### **Phase 5: Monitoring and Incident Analysis**

**Commands to Execute:**
```bash
# Comprehensive event timeline
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp'

# Failover controller operational logs
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=50

# Resource utilization deep dive
kubectl describe pods -n sre-companion-demo
```

**Follow-up AI Queries:**
- **Query 1** (GPT-4o): *"Reconstruct the timeline of our last major failure including user impact assessment and recovery actions taken."*
- **Query 2** (Claude Sonnet 4): *"Draft a comprehensive incident report with root cause analysis and prevention strategies for future incidents."*

### **Multi-Agent Comparative Analysis Workflow**

**Cross-Domain Agent Testing:**

**Kubernetes Operations Analysis:**
```bash
# Query k8s-agent with GPT-4o
```
*"Provide immediate cluster health assessment and scaling recommendations."*

```bash
# Switch to Claude Sonnet 4 with same k8s-agent
```
*"Conduct comprehensive cluster architecture analysis with long-term optimization roadmap."*

**Network Troubleshooting Scenario:**
```bash
# Query cilium-debug-agent with GPT-4o
```
*"Diagnose any network connectivity issues and provide immediate fixes."*

```bash
# Switch to Claude Sonnet 4 with cilium-debug-agent  
```
*"Analyze network topology and design comprehensive security policy architecture."*

**Observability Strategy Development:**
```bash
# Query observability-agent with GPT-4o
```
*"Interpret current metrics and provide immediate alert triage recommendations."*

```bash
# Switch to Claude Sonnet 4 with observability-agent
```
*"Design comprehensive monitoring strategy with SLI/SLO framework and alerting optimization."*

### **Collaborative Multi-Agent Scenarios**

**Incident Response Chain:**
1. Query `k8s-agent` (GPT-4o) → *"Quick cluster health check and immediate response actions"*
2. Query `observability-agent` (Claude Sonnet 4) → *"Comprehensive incident analysis and monitoring strategy improvements"*
3. Query `sre-companion` (Both providers) → *"Compare incident response approaches and document lessons learned"*

**Deployment Optimization Workflow:**
1. Query `argo-rollouts-conversion-agent` (GPT-4o) → *"Fast deployment pattern conversion recommendations"*
2. Query `sre-companion` (Claude Sonnet 4) → *"Strategic reliability engineering assessment of deployment patterns"*
3. Query `helm-agent` (Both providers) → *"Compare chart management approaches for reliability optimization"*

---

## Getting Started

Ready to explore dual-provider AI-powered SRE operations? Follow these steps:

1. **Prerequisites**: Ensure you have Docker, Kubernetes (kubectl), Helm, and Minikube installed
2. **API Keys**: Set up your `ANTHROPIC_API_KEY` and `OPENAI_API_KEY` environment variables
3. **Deploy**: Run `./scripts/setup-sre-companion.sh` for complete environment provisioning
4. **Explore**: Access the Kagent UI at http://localhost:8081 and start querying your 11-agent ecosystem
5. **Experiment**: Try the demonstration phases above, switching between AI providers to compare reasoning approaches

## What Makes This Special

This isn't just another SRE demo—it's a **comprehensive AI operations research platform** that demonstrates:

- **Multi-agent specialization** across 11 different operational domains
- **Dual-provider AI comparison** showing different reasoning approaches to identical problems
- **Collaborative workflows** between specialized agents using different AI models
- **Real-world operational scenarios** with authentic challenges and learning opportunities
- **Production-ready practices** implemented through modern SRE automation patterns

Whether you're exploring AI-augmented operations, learning about blue/green deployments, or researching comparative AI reasoning in infrastructure management, this platform provides hands-on experience with the future of Site Reliability Engineering.

---

**Happy exploring the future of AI-powered operations!**

![Kagent SRE Demo](https://img.shields.io/badge/Kagent-SRE%20Demo-purple) ![Dual Provider AI](https://img.shields.io/badge/Dual%20Provider-AI%20Ops-blue) ![Multi Agent](https://img.shields.io/badge/Multi%20Agent-Ecosystem-green)