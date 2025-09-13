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

## Interactive Demonstration Framework

The demonstration progresses through eight comprehensive phases that showcase increasing complexity in dual-provider AI-augmented SRE practices. Each phase combines hands-on script execution with comparative AI analysis to create realistic operational scenarios.

### **Phase 1: Initial Discovery and Baseline Assessment**

Begin the demonstration by establishing comprehensive cluster awareness through direct Kubernetes API interactions combined with dual AI-powered analysis. This phase establishes operational baselines and identifies system dependencies.

**Cluster State Discovery:**
```bash
kubectl get pods -n sre-companion-demo
kubectl get deployments,services -n sre-companion-demo
kubectl describe service web -n sre-companion-demo
```

**Baseline Performance Establishment:**
```bash
# Establish performance baseline with light load
./scripts/load-test.sh 60 50 200
```

**Comparative AI Analysis Queries:**
- *"What is the current state of my blue/green deployment? Analyze pod health, service routing configuration, and resource allocation patterns."* (Both providers)
- *"What are the resource requests and limits for each deployment, and are they appropriately sized for the workload?"* (GPT-4o for quick assessment)
- *"Analyze the baseline performance metrics and establish comprehensive SLA benchmarks with industry comparisons."* (Claude Sonnet 4 for detailed analysis)

### **Phase 2: Configuration Analysis and Security Assessment**

Conduct comprehensive configuration review and security posture assessment to identify potential vulnerabilities and optimization opportunities before proceeding with operational testing.

**Configuration Review:**
```bash
kubectl describe deployment web-blue -n sre-companion-demo
kubectl describe deployment web-green -n sre-companion-demo
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp'
```

**Comparative AI Analysis Queries:**
- *"Analyze the security configuration of my deployments. Are there any vulnerabilities or misconfigurations?"* (Both providers for comparison)
- *"Review the health probe settings - are they optimally configured for this application type?"* (GPT-4o for technical assessment)
- *"Design a comprehensive security audit checklist based on current configuration analysis."* (Claude Sonnet 4 for strategic framework)

### **Phase 3: Controlled Failure Injection and Recovery Analysis**

Execute controlled failure scenarios using the failure simulation script to demonstrate autonomous recovery capabilities and measure system resilience. This phase combines immediate failures with controlled outages to test different recovery patterns.

**Immediate Pod Failure Testing:**
```bash
# Start continuous monitoring
kubectl get pods -n sre-companion-demo -w &

# Trigger immediate pod deletion (tests self-healing)
./scripts/simulate-failure.sh blue

# Monitor recovery process
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp' | tail -10
```

**Controlled Outage Simulation:**
```bash
# Execute controlled outage with predictable timing
./scripts/simulate-failure.sh blue --outage 30

# Test standby deployment failover
./scripts/simulate-failure.sh green --outage 15
```

**Comparative AI Analysis Queries:**
- *"Analyze the failover event timing and recovery process. What was the Mean Time To Recovery?"* (GPT-4o for metrics analysis)
- *"How did the autonomous failover controller respond to the blue deployment failure?"* (Both providers)
- *"Design resilience improvement strategies based on observed failure patterns and industry best practices."* (Claude Sonnet 4 for strategic planning)

### **Phase 4: Progressive Load Testing and Performance Analysis**

Conduct comprehensive load testing using progressive traffic patterns to understand system behavior under various load conditions. This phase combines load generation with real-time performance analysis and scaling behavior assessment.

**Progressive Load Escalation:**
```bash
# Light load baseline
./scripts/load-test.sh 120 50 200
# AI Query (GPT-4o): "Establish our performance baseline during light load conditions"

# Medium load testing
./scripts/load-test.sh 120 150 400  
# AI Query (Both): "How do response times and resource utilization change as load increases?"

# Heavy load stress testing
./scripts/load-test.sh 120 300 700
# AI Query (Claude): "Identify performance degradation patterns and recommend comprehensive scaling strategies"
```

**Comparative AI Analysis Queries:**
- *"What are our current performance bottlenecks and capacity limits?"* (GPT-4o for immediate assessment)
- *"Compare current performance against our SLA requirements and industry benchmarks with detailed improvement recommendations."* (Claude Sonnet 4 for comprehensive analysis)
- *"Design optimal resource allocation and autoscaling policies based on observed load patterns."* (Both providers for comparison)

### **Phase 5: Advanced Monitoring and Alerting Optimization**

Focus on monitoring stack optimization, custom metrics creation, and alert threshold tuning based on observed operational patterns. This phase leverages dual AI analysis to improve observability and reduce alert fatigue.

**Monitoring Analysis:**
```bash
# Review current monitoring configuration
kubectl get servicemonitor -n monitoring
kubectl describe prometheusrule -n monitoring

# Analyze alert history
kubectl logs -n monitoring prometheus-prom-stack-kube-prometheus-prometheus-0 | grep WARN
```

**Comparative AI Analysis Queries:**
- *"Create custom alerts based on the failure patterns we've observed."* (GPT-4o for technical implementation)
- *"Design a comprehensive monitoring strategy that aligns with SRE best practices and reduces alert fatigue."* (Claude Sonnet 4 for strategic framework)
- *"Recommend specific SLIs and SLOs for this application based on observed operational patterns."* (Both providers for comparison)

### **Phase 6: Chaos Engineering and Combined Scenarios**

Execute sophisticated chaos engineering scenarios that combine load testing with failure injection to simulate realistic production incident conditions. This phase tests system resilience under complex multi-failure scenarios.

**Cascading Failure Simulation:**
```bash
# Start sustained load
./scripts/load-test.sh 300 200 500 &

# Create cascading failure scenario
sleep 60
./scripts/simulate-failure.sh blue --outage 60
sleep 30
./scripts/simulate-failure.sh green --outage 30
```

**Comparative AI Analysis Queries:**
- *"Analyze this cascading failure scenario and identify recovery patterns."* (GPT-4o for immediate analysis)
- *"Design comprehensive chaos engineering strategies and failure injection frameworks based on observed system behavior."* (Claude Sonnet 4 for strategic planning)
- *"What's our current blast radius, and how can we implement circuit breaker patterns to reduce it?"* (Both providers for comparison)

### **Phase 7: Incident Response and Root Cause Analysis**

Conduct comprehensive incident analysis using dual AI-powered correlation of events, metrics, and logs to understand system behavior during failures. This phase emphasizes operational troubleshooting skills and documentation practices.

**Timeline Reconstruction:**
```bash
# Gather comprehensive incident data
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp'
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=100
kubectl describe pods -n sre-companion-demo
```

**Comparative AI Analysis Queries:**
- *"Reconstruct the timeline of the last major failure including user impact assessment."* (GPT-4o for rapid timeline creation)
- *"Draft a comprehensive incident report with root cause analysis, business impact assessment, and detailed prevention strategies."* (Claude Sonnet 4 for thorough documentation)
- *"Design incident response procedures and communication templates for different stakeholder groups."* (Both providers for comparison)

### **Phase 8: Strategic Optimization and Capacity Planning**

Synthesize insights from all previous phases to develop comprehensive optimization strategies and long-term capacity planning. This phase focuses on strategic improvements and architectural recommendations.

**Performance Optimization Validation:**
```bash
# Test current configuration performance
./scripts/load-test.sh 180 200 500
# AI: "Document current performance metrics as optimization baseline"

# Test optimizations under failure conditions
./scripts/load-test.sh 240 250 600 &
./scripts/simulate-failure.sh blue --outage 45
# AI: "Did our optimizations improve failover behavior and recovery times?"
```

**Strategic Planning Queries:**
- *"Analyze our resource utilization patterns and suggest cost optimization opportunities."* (GPT-4o for technical analysis)
- *"Design a comprehensive 6-month reliability engineering roadmap based on observed operational patterns and industry best practices."* (Claude Sonnet 4 for strategic planning)
- *"Project our infrastructure capacity needs for 3x traffic growth over the next year with detailed scaling strategies."* (Both providers for comparison)

## Demo Format Options

### **Basic Demo (45-60 minutes)**
Focus on core dual-provider operational scenarios:
- **Phase 1**: Initial Discovery with AI comparison (10 min)
- **Phase 3**: Controlled Failure Testing with dual analysis (15 min)
- **Phase 4**: Load Testing with provider switching (15 min)
- **Phase 6**: Simple Chaos Scenario with comparative insights (10 min)
- **Phase 8**: Optimization Recommendations comparison (5 min)

### **Comprehensive Demo (90-120 minutes)**
Complete dual-provider operational assessment:
- All 8 phases with full comparative AI analysis
- Multiple script scenarios per phase with provider switching
- Detailed discussion of AI reasoning differences
- Interactive Q&A with both AI providers

### **Workshop Format (2-3 hours)**
Hands-on dual-provider learning experience:
- **Part 1**: Individual script exploration with AI guidance (45 min)
- **Part 2**: Guided scenario execution with provider comparison (60 min)
- **Part 3**: Custom failure design exercise with dual AI consultation (45 min)
- **Part 4**: Strategic discussion and planning with both providers (30 min)

## System Validation and Health Verification

Comprehensive system validation requires regular execution of diagnostic commands across all system components to ensure proper operation and dual AI provider integration. These validation procedures should be incorporated into regular operational routines and automated monitoring frameworks.

**Dual AI Provider Verification:**
```bash
kubectl get modelconfigs -n kagent
kubectl get agents -n kagent  
kubectl describe agent sre-companion -n kagent
```

**Deployment and Pod Health Assessment:**
```bash
kubectl get deployments,pods -n sre-companion-demo -l app=web
kubectl describe deployment web-blue -n sre-companion-demo
kubectl describe deployment web-green -n sre-companion-demo
```

**Service Routing and Network Connectivity Verification:**
```bash
kubectl describe svc web -n sre-companion-demo
kubectl get endpoints web -n sre-companion-demo
```

**Failover Controller Operations and Event History:**
```bash
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=50
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp'
```

## Troubleshooting Common Operational Issues

### **Dual AI Provider Issues and Workarounds**

**Model Switching Failures** - If switching between providers fails in the Kagent UI, verify that both ModelConfig resources are properly applied, API keys are valid and have sufficient credits, and the kagent-controller is running without errors. Use `kubectl logs deployment/kagent-controller -n kagent` to identify provider connectivity issues.

**Provider-Specific Response Differences** - The dual providers may give different recommendations for identical queries. This is expected behavior and demonstrates the value of comparative AI analysis. GPT-4o typically provides faster, more tool-focused responses, while Claude Sonnet 4 offers deeper analytical reasoning and strategic insights.

**API Rate Limiting** - During intensive testing with frequent AI queries, you may encounter rate limits. Implement query pacing or alternate between providers to maintain operational continuity while staying within API limits.

### **Script Execution Issues**

**Port Forwarding Connectivity Issues** can often be resolved through process cleanup and session restart without requiring complete system redeployment. Identify conflicting processes using `lsof` commands and terminate as necessary before re-establishing port forwarding sessions.

**Load Test Script Failures** may result from insufficient cluster resources or competing workloads. Monitor resource utilization during tests and adjust concurrency parameters or cluster allocation accordingly.

**Failure Simulation Script Issues** typically indicate RBAC permission problems or invalid deployment targets. Verify that the target deployments exist and that the script has appropriate permissions to scale deployments.

### **Infrastructure and Resource Issues**

**Resource Constraint and Pod Scheduling Issues** typically indicate insufficient Minikube resource allocation or competing workloads consuming available capacity. Address through cluster resource scaling or workload optimization based on actual resource utilization patterns observed through monitoring dashboards.

**Failover Controller Operation Failures** may result from RBAC permission issues, network connectivity problems, or service configuration inconsistencies. Examine controller logs, verify RBAC permissions, and validate service endpoint availability to identify and resolve underlying causes.

## Intentional Limitations and Educational Opportunities

This demonstration deliberately incorporates real-world operational challenges and limitations to provide authentic learning experiences and highlight the importance of human oversight in dual AI-augmented operations. These intentional constraints serve as valuable teaching moments for understanding the complexities of modern distributed systems management and AI reasoning diversity.

**Dual AI Provider Comparison Opportunities** showcase how different AI models approach identical operational challenges with varying reasoning patterns, response speeds, and recommendation depths. This realistic scenario demonstrates the value of comparative AI analysis in complex operational decision-making while highlighting the continued importance of human judgment in synthesizing diverse AI recommendations.

**API Rate Limiting Challenges** show how external service dependencies can impact operational workflows, emphasizing the need for proper rate limiting strategies, fallback mechanisms, and service degradation planning in AI-augmented operations environments.

**Service Configuration Dependencies and Routing Complexities** may cause traffic routing to deployments with zero available pods, creating authentic outage scenarios that demonstrate the value of proper health checking, traffic management policies, and automated recovery mechanisms. These scenarios provide excellent opportunities for comparative AI analysis of incident response strategies.

These intentional challenges provide realistic scenarios for practicing dual AI consultation methodologies, understanding the complementary nature of different AI reasoning approaches, and appreciating the nuanced relationship between multiple AI providers and human operational expertise in critical SRE decision-making processes.