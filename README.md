# SRE Companion Demo: AI-Powered Operations with Kagent

This repository demonstrates how **Kagent** transforms traditional Site Reliability Engineering (SRE) practices through **AI-powered cluster operations**. Rather than showcasing perfect workflows, this demo deliberately exposes real-world challenges — incomplete metrics, rate limits, and service misconfigurations — transforming them into valuable learning opportunities for modern SRE practices.

The demonstration encompasses intelligent blue/green deployment management, autonomous failover capabilities, conversational cluster operations with AI agents, and seamless integration of monitoring, load testing, and failure simulation into cohesive operational scenarios.

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

### AI Platform Integration (`kagent/`)

The **`kagent/`** directory contains the complete configuration for AI-powered operational capabilities. The **`modelconfig.yaml`** establishes connections to large language models (Claude Sonnet 4 and OpenAI GPT-4), enabling natural language interfaces for complex operational queries and analysis.

The **`agent.yaml`** and **`failover-agent-config.yaml`** define specialized AI agents with domain-specific knowledge for SRE operations. These agents possess deep understanding of blue/green deployment patterns, failover scenarios, and Kubernetes operational best practices. The **`mcpserver.yaml`** configures Model Context Protocol servers that provide secure, controlled access to cluster resources for AI agents.

The **`memory.yaml`** and **`session.yaml`** files enable persistent context and conversation state management, allowing AI agents to maintain awareness of ongoing operations and historical decisions. The **`monitoring/values.yaml`** customizes Prometheus stack deployment with demo-specific configurations that enhance AI agent access to metrics and alerting data.

### Monitoring and Observability (`grafana/`)

The **`sre-demo-dashboard.json`** provides a comprehensive Grafana dashboard specifically designed for blue/green deployment monitoring. The dashboard includes memory and CPU utilization tracking per pod, restart pattern analysis, replica count visualization for both deployment versions, and correlation views that help identify relationships between resource consumption and application performance.

This dashboard integrates seamlessly with AI agent queries, enabling natural language access to complex metrics analysis and trend identification. The visualization design emphasizes operational decision-making rather than just data display, making it valuable for both human operators and AI-powered analysis.

### Container Image (`Dockerfile`)

The **`Dockerfile`** implements security and performance best practices for containerized applications. The multi-stage approach uses Python 3.11 slim base images to minimize attack surface while maintaining compatibility. Environment variable configuration enables dynamic behavior modification without requiring image rebuilds, supporting the blue/green deployment pattern through runtime customization.

Resource optimization techniques including dependency caching and minimal layer construction reduce image size and build times while ensuring reliable deployment performance across different cluster environments.

### Automation Scripts (`scripts/`)

The **`setup-sre-companion.sh`** script provides comprehensive environment provisioning with robust error handling and validation. The script implements prerequisite checking, API key validation, Docker runtime management, and sequential deployment of all system components. The automation includes service health verification, port forwarding configuration, and automatic browser launching for immediate access to all system interfaces.

The **`load-test.sh`** script generates controlled traffic patterns for performance testing and scaling demonstrations. The configurable parameters (duration, concurrency, CPU burn) enable reproduction of various operational scenarios including traffic spikes, sustained load conditions, and failover testing under stress.

The **`simulate-failure.sh`** script provides controlled chaos engineering capabilities with two distinct failure modes. The pod deletion mode triggers immediate self-healing demonstrations, while the outage mode creates predictable failover scenarios with controlled recovery timelines. Both modes generate comprehensive logging and integration with the monitoring stack.

The **`cleanup.sh`** script ensures complete environment removal including Minikube cluster destruction, Docker context cleanup, and artifact removal. This enables reliable reset capabilities for repeated demonstrations and different configuration testing.

## Quick Deployment and Configuration

### Prerequisites and Environment Setup

Successful deployment requires Docker, Kubernetes (kubectl), Helm, and Minikube installed with appropriate system resource allocation. The minimum recommended configuration includes 8 CPU cores, 16GB RAM, and 40GB disk space for complete functionality including AI model operations and comprehensive monitoring.

Configure your Anthropic API key through environment variable export to enable AI-powered operational capabilities:

```bash
# Configure AI model access
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

This process provisions the Flask demonstration application with blue/green configuration, complete monitoring stack including Prometheus and Grafana with custom dashboards, autonomous failover controller with comprehensive permissions and monitoring logic, and the Kagent AI platform with integrated agent capabilities and model configurations.

### Service Access and Port Management

The deployment automatically configures port forwarding for all services and launches browser windows for immediate access. Manual port forwarding configuration enables flexible access patterns:

### Access Points

* **[Application interface](http://localhost:8082)**

```bash
kubectl -n sre-companion-demo port-forward service/web 8082:80
```

* **[Kagent AI dashboard](http://localhost:8081)**

```bash
kubectl -n kagent port-forward service/kagent-ui 8081:80
```

* **[Grafana monitoring dashboard](http://localhost:3000)**

```bash
kubectl -n monitoring port-forward service/prom-stack-grafana 3000:80
```

* **[Prometheus monitoring dashboard](http://localhost:9090)**

```bash
kubectl -n monitoring port-forward svc/prom-stack-kube-prometheus-prometheus 9090:9090
```

Port conflict resolution may require process termination when ports remain bound after session closure:

```bash
# Identify processes using demo ports
lsof -i :8082 -i :8081 -i :3000 -i :9090

# Terminate specific processes (use with caution)
kill -9 <PID>
```

## Operational Scenarios and Testing Framework

### Load Testing and Performance Validation

The integrated load testing framework enables controlled traffic generation for autoscaling demonstrations, failover validation, and performance baseline establishment. The testing utility provides configurable parameters for duration, concurrency, and per-request CPU consumption:

```bash
# Baseline performance test (120s duration, 150 concurrent requests, 500ms CPU burn)
./scripts/load-test.sh

# Traffic spike simulation (120s duration, 300 concurrent requests, 800ms CPU burn)
./scripts/load-test.sh 120 300 800

# Extended failover test (240s duration, 100 concurrent requests, 400ms CPU burn)
./scripts/load-test.sh 240 100 400
```

These scenarios populate monitoring dashboards with realistic operational data, trigger Horizontal Pod Autoscaler policies for scaling demonstrations, and provide controlled conditions for autonomous failover testing.

### Failure Simulation and Recovery Testing

The failure simulation framework provides two distinct modes for different operational learning objectives. Pod deletion mode demonstrates Kubernetes self-healing capabilities through immediate pod replacement, while outage mode creates controlled traffic switching scenarios with predictable recovery timelines:

```bash
# Immediate pod deletion (triggers self-healing)
./scripts/simulate-failure.sh blue

# Controlled outage with automatic recovery (30-second outage)
./scripts/simulate-failure.sh blue --outage 30

# Green deployment outage simulation
./scripts/simulate-failure.sh green --outage 15
```

### Interactive AI-Powered Operations

The demonstration framework progresses through five operational phases that showcase increasing complexity in AI-augmented SRE practices.

**Phase 1: Cluster State Assessment** begins with direct Kubernetes API interaction combined with AI-powered analysis. Execute `kubectl get pods -n sre-companion-demo` to establish baseline cluster state, then engage the AI system with contextual queries such as *"What is the current state of my blue/green deployment? Analyze pod health, service routing configuration, and resource utilization patterns."*

**Phase 2: Failover Event Simulation** demonstrates autonomous recovery capabilities through controlled failure injection. Scale the blue deployment to zero replicas using `kubectl scale deployment web-blue --replicas=0 -n sre-companion-demo` or execute the automated failure simulation script. Query the AI system for comprehensive analysis: *"Did a failover event occur just now? Provide detailed analysis including transition timing, affected services, recovery metrics, and recommendations for optimization."*

**Phase 3: Load Testing and Scaling Analysis** combines performance testing with AI-powered analysis of system behavior under stress. Execute comprehensive load testing with `./scripts/load-test.sh 300 200 1000` while requesting AI analysis: *"How are the deployment pods performing under the current stress test? Analyze resource utilization patterns, scaling events, performance degradation indicators, and capacity planning recommendations."*

**Phase 4: Root Cause Analysis and Event Correlation** demonstrates advanced troubleshooting capabilities through log analysis and cross-system event correlation. Examine controller logs using `kubectl logs deployment/failover-controller -n sre-companion-demo` and engage AI for comprehensive analysis: *"Correlate failover-controller events with CPU metrics, service routing changes, and user impact indicators. Identify anomalies, optimization opportunities, and preventive measures."*

**Phase 5: Strategic Optimization Recommendations** leverages AI-powered analysis for long-term system improvement recommendations. Request strategic guidance: *"Based on observed failover patterns, performance metrics, and operational events, provide specific recommendations for reducing Mean Time To Recovery, optimizing health probe configurations, implementing predictive scaling policies, and enhancing overall system resilience."*

## AI-Powered Operational Capabilities

The Kagent platform delivers sophisticated operational capabilities that extend traditional SRE practices through natural language interfaces and intelligent automation. **Cluster Analysis** functionality provides comprehensive service health assessments, deployment state evaluations, resource utilization analysis, and intelligent recommendations based on observed patterns and industry best practices.

**Scaling Operations** encompass automated Horizontal Pod Autoscaler creation with customized policies, continuous monitoring of scaling events with trend analysis, proactive capacity planning based on historical patterns, and integration with load testing frameworks for validation of scaling policies under controlled conditions.

**Failure Diagnosis** capabilities include analysis of pod restart patterns with root cause identification, health probe failure investigation with configuration recommendations, correlation of controller events with system-wide metrics and user impact assessment, and predictive failure analysis based on trend identification and anomaly detection.

**Strategic Advisory Services** provide health probe configuration optimization based on application characteristics and performance requirements, autoscaling policy recommendations tailored to workload patterns and resource constraints, service mesh integration guidance for enhanced observability and traffic management, and disaster recovery planning with automated failover validation and recovery time optimization.

## SRE Principles Integration and Best Practices

The demonstration embodies core Site Reliability Engineering principles through practical implementation patterns that showcase production-ready operational methodologies. **Observability** enhancement occurs through AI-powered query interfaces that unify Prometheus metrics with log analysis, structured event correlation across multiple system components, and human-friendly summarization of complex system states and performance trends.

**Automation** capabilities reduce Mean Time To Recovery through autonomous traffic switching during outage scenarios, predictive scaling based on workload patterns and resource utilization trends, intelligent alert routing and escalation based on service impact assessment, and self-healing infrastructure with comprehensive audit trails and rollback capabilities.

**Reliability Engineering** practices include chaos engineering democratization through controlled failure injection with AI-powered analysis, comprehensive testing frameworks that validate system behavior under various failure conditions, capacity planning optimization through historical analysis and predictive modeling, and incident response automation with natural language interfaces for rapid diagnosis and resolution.

**Knowledge Sharing** facilitation occurs through conversational AI interfaces that make specialized SRE expertise accessible to team members with varying experience levels, automated documentation generation based on operational events and system changes, and collaborative troubleshooting capabilities that preserve institutional knowledge and accelerate problem resolution.

## System Validation and Health Verification

Comprehensive system validation requires regular execution of diagnostic commands across all system components to ensure proper operation and integration. These validation procedures should be incorporated into regular operational routines and automated monitoring frameworks.

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
kubectl get ingress -n sre-companion-demo
```

**Autoscaling Configuration and Status Monitoring:**
```bash
kubectl get hpa -n sre-companion-demo
kubectl describe hpa web-blue-hpa -n sre-companion-demo
kubectl describe hpa web-green-hpa -n sre-companion-demo
```

**Failover Controller Operations and Event History:**
```bash
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=50
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp'
```

## Troubleshooting Common Operational Issues

**API Key Configuration Problems** typically manifest as authentication errors in AI agent operations or model configuration failures. Verify that Anthropic or OpenAI secrets are properly configured in the `kagent` namespace using `kubectl get secrets -n kagent` and ensure API keys have sufficient permissions and quota for the expected operational load.

**Port Forwarding Connectivity Issues** can often be resolved through process cleanup and session restart without requiring complete system redeployment. Identify conflicting processes using `lsof` commands and terminate as necessary before re-establishing port forwarding sessions.

**Metrics Collection and Dashboard Display Problems** may occur due to incomplete Prometheus configuration or missing service monitor definitions. The demonstration application intentionally lacks comprehensive instrumentation to simulate real-world gaps in observability, requiring operators to identify and address monitoring blind spots.

**Resource Constraint and Pod Scheduling Issues** typically indicate insufficient Minikube resource allocation or competing workloads consuming available capacity. Address through cluster resource scaling or workload optimization based on actual resource utilization patterns observed through monitoring dashboards.

**Failover Controller Operation Failures** may result from RBAC permission issues, network connectivity problems, or service configuration inconsistencies. Examine controller logs, verify RBAC permissions, and validate service endpoint availability to identify and resolve underlying causes.

## Intentional Limitations and Educational Opportunities

This demonstration deliberately incorporates real-world operational challenges and limitations to provide authentic learning experiences and highlight the importance of human oversight in AI-augmented operations. These intentional constraints serve as valuable teaching moments for understanding the complexities of modern distributed systems management.

**AI Model Integration Constraints** require exact model identifiers and version specifications for proper API integration, demonstrating the importance of infrastructure-as-code practices and version management in operational environments. **API Rate Limiting Challenges** show how external service dependencies can impact operational workflows, emphasizing the need for proper rate limiting strategies, fallback mechanisms, and service degradation planning.

**Observability Gaps and Metrics Collection Limitations** occur through incomplete application instrumentation, resulting in empty Prometheus queries for certain metrics categories. This realistic scenario highlights the critical importance of comprehensive monitoring strategies, instrumentation planning, and observability-driven development practices in production environments.

**Service Configuration Dependencies and Routing Complexities** may cause traffic routing to deployments with zero available pods, creating authentic outage scenarios that demonstrate the value of proper health checking, traffic management policies, and automated recovery mechanisms. **Resource Limit and Scaling Dependencies** can cause AI recommendations to fail when deployments lack proper resource specifications, illustrating the interconnected nature of Kubernetes resource management and autoscaling policies.

These intentional "failures" provide realistic scenarios for practicing troubleshooting methodologies, understanding distributed systems complexities, and appreciating the nuanced relationship between automated systems and human operational expertise. They demonstrate why AI augments rather than replaces human judgment in critical operational decisions and reinforce the importance of comprehensive system design, monitoring, and operational procedures in modern SRE practices.