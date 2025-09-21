# Practical Demonstration Runbook: "The DNA of SRE with Kagent"

## Initial Environment Setup

### Pre-requisite Verification

```bash
# 1. Verify all agents are available
kubectl get agents -n kagent

# 2. Confirm deployment status
kubectl get pods,deployments,services -n sre-companion-demo
```

### Service Access and Port Management

The deployment automatically configures port forwarding for all services and launches browser windows for immediate access. Manual port forwarding configuration enables flexible access patterns.

#### Access Points

**Application interface (blue/green demonstration)**
```bash
kubectl -n sre-companion-demo port-forward service/web 8082:80
```
[Open Application](http://localhost:8082)

**Kagent AI dashboard (dual-provider conversational operations)**
```bash
kubectl -n kagent port-forward service/kagent-ui 8081:80
```
[Open Kagent UI](http://localhost:8081)

**Grafana monitoring dashboard (metrics and visualization)**
```bash
kubectl -n monitoring port-forward service/prom-stack-grafana 3000:80
```
[Open Grafana](http://localhost:3000)

**Prometheus monitoring dashboard (raw metrics access)**
```bash
kubectl -n monitoring port-forward svc/prom-stack-kube-prometheus-prometheus 9090:9090
```
[Open Prometheus](http://localhost:9090)

#### Port Conflict Resolution

Port conflict resolution may require process termination when ports remain bound after session closure.

```bash
# Identify processes using demo ports
lsof -i :8082 -i :8081 -i :3000 -i :9090

# Terminate specific processes (use with caution)
kill -9 <PID>
```

#### Service Status Validation

```bash
# Verify all port forwards are active
netstat -an | grep LISTEN | grep -E "(8081|8082|3000|9090)"

# Check service health endpoints
curl -s http://localhost:8082/healthz
curl -s http://localhost:8081/health || echo "Kagent UI may take a moment to start"

# Verify Grafana credentials
kubectl get secret prom-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
echo ""  # Add newline after password
```

---

## Exercise 1: Initial System Analysis with K8s-Agent

### Objective
Demonstrate cluster initial assessment capabilities

### Command Script
```bash
# System baseline status
kubectl get pods -n sre-companion-demo -o wide
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | head -300
```

### Question Sequence for k8s-agent

**Configuration:** Use **OpenAI GPT-4o** (rapid assessment)

1. **"What is the current health status of my cluster? Focus on the sre-companion-demo namespace"**
   - Expected: Quick assessment of pods, deployments, services

2. **"Analyze the resource configuration (CPU/memory) of my blue and green deployments. Are they optimized?"**
   - Expected: Analysis of resource requests/limits

3. **"Are there any potential issues you can identify in the current configuration?"**
   - Expected: Issue identification like green deployment with 0 replicas

**Switch to Anthropic Claude Sonnet 4:**

4. **"Based on the current configuration, design a capacity planning strategy for the next 6 months"**
   - Expected: Strategic analysis and long-term recommendations

5. **"What security improvements would you recommend for this blue/green deployment configuration?"**
   - Expected: Detailed hardening recommendations

---

## Exercise 2: Load Testing Implementation with sre-companion

### Objective
Demonstrate your custom agent capabilities under load

### Command Script
```bash
# Execute light load test
./scripts/load-test.sh 60 50 200
```

### Question Sequence for sre-companion

**Configuration:** Use **OpenAI GPT-4o** (rapid operational response)

1. **"I'm running a load test. What is the current state of my blue/green deployment during the load?"**
   - Expected: Real-time status assessment

2. **"Are the pods handling the load well? Should I scale?"**
   - Expected: Immediate scaling recommendations

### Intensify the Load
```bash
# More aggressive load test
./scripts/load-test.sh 120 150 500
```

3. **"Analyze the system behavior with this more intense load. Is there any degradation?"**
   - Expected: Performance impact analysis

**Switch to Anthropic Claude Sonnet 4:**

4. **"Based on the behavior observed during the load tests, what patterns do you identify and what optimization strategies would you recommend?"**
   - Expected: Deep pattern analysis and strategy

5. **"Design a complete load testing and capacity planning framework for this type of application"**
   - Expected: Comprehensive methodological framework

---

## Exercise 3: Failure Simulation and Failed Disaster Recovery

### Objective
Demonstrate realistic DR gaps and AI-powered troubleshooting of failed failover scenarios

### Command Script
```bash
# Verify current state - green should have 0 replicas (unprepared standby)
kubectl get deployments -n sre-companion-demo

# Simulate immediate failure (pod deletion) to see self-healing
./scripts/simulate-failure.sh blue

# Observe recovery behavior
kubectl get pods -n sre-companion-demo -o wide
```

### Question Sequence for sre-companion

**Configuration:** Use **OpenAI GPT-4o** (incident response)

1. **"I just simulated a failure in the blue deployment. What's happening with pod recovery and overall service availability?"**
   - Expected: Assessment of Kubernetes self-healing vs service-level impact

2. **"The pods are recovering quickly, but what would happen if I had a sustained outage instead of just pod deletion?"**
   - Expected: Analysis of failover controller behavior and green deployment readiness

### Controlled Outage with Failed Failover
```bash
# Create sustained outage scenario (this will expose the DR gap)
./scripts/simulate-failure.sh blue --outage 60

# Monitor what happens during the outage
kubectl get service web -n sre-companion-demo -o yaml | grep -A 5 selector
kubectl get endpoints web -n sre-companion-demo
kubectl get pods -n sre-companion-demo
```

3. **"I'm running a 60-second outage on blue deployment. The failover controller should activate - what's the current service state and is failover working?"**
   - Expected: AI should identify that failover activated but green has no capacity

**Switch to Anthropic Claude Sonnet 4:**

4. **"The failover controller switched traffic to green, but I still have no service availability. This represents a critical DR gap. Analyze what went wrong and what this teaches us about disaster recovery preparation."**
   - Expected: Detailed analysis of standby environment readiness failures

5. **"Design a comprehensive disaster recovery validation framework that would prevent this type of 'successful failover to nowhere' scenario in production environments."**
   - Expected: Framework including standby validation, automated readiness checks, DR testing procedures

### Post-Incident Analysis
```bash
# Check failover controller logs to see what it detected
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=20

# Verify current service routing after the incident
kubectl get service web -n sre-companion-demo -o jsonpath='{.spec.selector}' && echo

# Check current deployment state
kubectl get deployments -n sre-companion-demo -o wide
```

### Additional Questions for Multi-Agent Analysis

**k8s-agent with OpenAI GPT-4o:**
6. **"From a cluster operations perspective, what happened during this failed failover? What should operations teams monitor to catch this type of issue?"**

**observability-agent with Anthropic Claude Sonnet 4:**
7. **"What monitoring and alerting strategies would detect this DR readiness gap before it becomes a production incident? Design alert conditions that would catch unprepared standby environments."**

---

## Exercise 4: Query Generation with promql-agent

### Objective
Demonstrate query generation and analysis capabilities

### Command Script
```bash
# Generate some activity to have metrics
./scripts/load-test.sh 90 100 300 &
```

### Question Sequence for promql-agent

**Configuration:** Use **OpenAI GPT-4o** (rapid query generation)

1. **"I have web-blue and web-green deployments in namespace sre-companion-demo. Using the kube_deployment_status_replicas and kube_deployment_spec_replicas metrics, create a query to show current vs desired replicas for both deployments."**
   - Expected: Specific query for replica monitoring

2. **"Create a PromQL query to calculate the availability ratio (available/desired) for my web-blue and web-green deployments using kube_deployment_status_replicas_available and kube_deployment_spec_replicas metrics."**
   - Expected: PromQL alerting rule

3. **"Generate a query to show the replica status of all my AI agents in the kagent namespace. I can see agents like k8s-agent, sre-companion, observability-agent, etc."**
   - Expected: Rate calculation query

**Switch to Anthropic Claude Sonnet 4:**

4. **"Create a query to show all deployment replica counts grouped by namespace, focusing on sre-companion-demo and kagent namespaces."**
   - Expected: Complete monitoring query suite

5. **"Write a PromQL alerting rule that fires when any deployment in sre-companion-demo namespace has desired replicas > 0 but available replicas = 0 for more than 30 seconds."**
   - Expected: Observability strategy framework

---

## Exercise 5: Cascade Failure Scenario

### Objective
Demonstrate complex incident handling with realistic multi-deployment failures

### Pre-Setup Commands
```bash
# First, prepare green deployment for realistic cascade scenario
kubectl scale deployment web-green -n sre-companion-demo --replicas=2

# Wait for green pods to be ready (essential for realistic failover)
kubectl wait --for=condition=ready pod -l app=web,version=green -n sre-companion-demo --timeout=120s

# Verify both deployments are healthy before starting
kubectl get pods -n sre-companion-demo -l app=web
```

### Command Script
```bash
# Create cascade failure scenario with prepared environment
./scripts/load-test.sh 180 200 600 &
LOAD_PID=$!

# Allow load to establish (60 seconds)
sleep 60

# Monitor initial state
echo "=== Initial State Under Load ==="
kubectl get pods -n sre-companion-demo -l app=web
kubectl get service web -n sre-companion-demo -o jsonpath='{.spec.selector}' && echo

# Blue failure while under load
echo "=== Initiating Blue Failure ==="
./scripts/simulate-failure.sh blue --outage 45

# Brief pause to observe failover
sleep 10
kubectl get service web -n sre-companion-demo -o jsonpath='{.spec.selector}' && echo

# After 20s total, green also fails (cascade begins)
sleep 10
echo "=== Initiating Green Failure (Cascade) ==="
./scripts/simulate-failure.sh green --outage 30

# Monitor total service outage
sleep 5
echo "=== Service Status During Cascade ==="
kubectl get endpoints web -n sre-companion-demo
curl -s http://localhost:8082/healthz || echo "SERVICE UNAVAILABLE"

# Stop load test
kill $LOAD_PID 2>/dev/null || true
```

### Multi-Agent Question Sequence

**k8s-agent with OpenAI GPT-4o:**
1. **"I have an incident! I started with load testing, then blue failed and traffic switched to green, but now green is also failing. What's the immediate cluster assessment?"**

**sre-companion with OpenAI GPT-4o:**
2. **"During this cascade failure, both my blue and green deployments are down simultaneously. What immediate mitigation actions do you recommend when all deployment versions are unavailable?"**

**observability-agent with Anthropic Claude Sonnet 4:**
3. **"Analyze the patterns of this cascade incident where failover worked initially but then we lost both environments. What metrics and alerts should we have monitored to prevent complete service unavailability?"**

**k8s-agent with Anthropic Claude Sonnet 4:**
4. **"Design a comprehensive recovery and prevention plan to avoid this type of cascade failures where automatic failover saves us initially but we still experience total outage. Include both technical and operational safeguards."**

### Post-Incident Verification
```bash
# Check current deployment state after cascade
kubectl get deployments -n sre-companion-demo -o wide

# Review failover controller logs for the incident
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=30

# Verify current service routing
kubectl get service web -n sre-companion-demo -o jsonpath='{.spec.selector}' && echo

# Check endpoint availability
kubectl get endpoints web -n sre-companion-demo
```

---

## Exercise 6: Observability and Metrics Analysis

### Objective
Demonstrate advanced monitoring data analysis

### Command Script
```bash
# Check failover controller logs
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=20

# Review recent events
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp'

# Verify endpoint status
kubectl get endpoints -n sre-companion-demo
```

### Question Sequence for observability-agent

**Configuration:** Use **OpenAI GPT-4o** (rapid metrics interpretation)

1. **"Analyze the recent failover controller logs. Are there concerning patterns?"**
   - Expected: Log analysis and pattern identification

2. **"What metrics are available for monitoring my blue/green deployments?"**
   - Expected: Available metrics inventory

3. **"What are the gaps in my current observability stack?"**
   - Expected: Immediate gap analysis

**Switch to Anthropic Claude Sonnet 4:**

4. **"Design a complete observability strategy for a production environment with blue/green deployments"**
   - Expected: Comprehensive observability strategy

5. **"How would you implement SLOs and error budgets for this type of setup?"**
   - Expected: Detailed SLO framework

---

## Exercise 7: Helm Management and Package Operations

### Objective
Demonstrate package management and dependencies

### Command Script
```bash
# Verify current releases
helm list -A

# See available prometheus charts
helm search repo prometheus-community | head -10
```

### Question Sequence for helm-agent

**Configuration:** Use **OpenAI GPT-4o** (rapid package operations)

1. **"What Helm releases are currently installed in my cluster?"**
   - Expected: Helm releases inventory

2. **"How can I safely update my Prometheus stack to the latest version?"**
   - Expected: Immediate upgrade strategy

3. **"If I need to rollback the monitoring stack, what would be the process?"**
   - Expected: Rollback procedure

**Switch to Anthropic Claude Sonnet 4:**

4. **"Design a lifecycle management strategy for Helm charts in an enterprise environment"**
   - Expected: Enterprise helm strategy

5. **"How would you structure a CI/CD process for chart deployment with proper testing?"**
   - Expected: CI/CD framework for helm

---

## Exercise 8: Final Comparative Analysis

### Objective
Demonstrate dual-provider approach value

### Command Script
```bash
# Final system state
kubectl get all -n sre-companion-demo
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp' | tail -10

# Verify services are healthy
curl -s http://localhost:8082/healthz
```

### Identical Question to Multiple Agents

Ask this question to ALL available agents, alternating between providers:

**"Based on all the activity we've performed during this demo (load tests, failures, recovery), what are the 3 most important recommendations to improve this system's reliability?"**

**Sequence:**
1. `sre-companion` with **OpenAI GPT-4o**
2. `sre-companion` with **Anthropic Claude Sonnet 4**
3. `k8s-agent` with **OpenAI GPT-4o**
4. `k8s-agent` with **Anthropic Claude Sonnet 4**
5. `observability-agent` with **OpenAI GPT-4o**
6. `observability-agent` with **Anthropic Claude Sonnet 4**

### Results Analysis
- Compare approach differences between providers
- Identify consistencies between specialized agents
- Show how different AI models reason about the same data

---

## Post-Demo Cleanup Commands

```bash
# Stop load tests if still running
pkill -f "load-test.sh" || true
pkill -f "curl.*18080" || true

# Verify final state
kubectl get pods -n sre-companion-demo
kubectl get service web -n sre-companion-demo -o yaml | grep -A 3 selector

# Optional: Reset to initial state
kubectl scale deployment web-blue -n sre-companion-demo --replicas=2
kubectl scale deployment web-green -n sre-companion-demo --replicas=0
kubectl patch service web -n sre-companion-demo -p '{"spec":{"selector":{"version":"blue"}}}'
```

---

## Key Points for Presentation

### Technical Highlights
- **11 specialized agents** working collaboratively
- **Dual-provider AI** showing different reasoning approaches
- **Real-time operations** with actual infrastructure
- **Production-ready patterns** in a demo environment

### Observable Differences Between Providers
- **OpenAI GPT-4o**: Faster responses, focus on immediate actions
- **Anthropic Claude Sonnet 4**: Deeper analysis, strategic planning

### Value Propositions
- **Reduced MTTR** through AI-assisted diagnosis
- **Consistent operations** across team members
- **Learning acceleration** for junior SREs
- **24/7 operational intelligence** without human fatigue