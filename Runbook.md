# Practical Demonstration Runbook: "The DNA of SRE with Kagent"

## **Initial Environment Setup**

### **Pre-requisite Verification**

```bash
# 1. Verify all agents are available
kubectl get agents -n kagent

# 2. Confirm deployment status
kubectl get pods,deployments,services -n sre-companion-demo
```

### **Service Access and Port Management**

The deployment automatically configures port forwarding for all services and launches browser windows for immediate access. Manual port forwarding configuration enables flexible access patterns:

#### **Access Points**

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

#### **Port Conflict Resolution**

Port conflict resolution may require process termination when ports remain bound after session closure:

```bash
# Identify processes using demo ports
lsof -i :8082 -i :8081 -i :3000 -i :9090

# Terminate specific processes (use with caution)
kill -9 <PID>
```

#### **Service Status Validation**

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

## **Exercise 1: Initial System Analysis with K8s-Agent**

### **Objective:** Demonstrate cluster initial assessment capabilities

### **Command Script:**
```bash
# System baseline status
kubectl get pods -n sre-companion-demo -o wide
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp' | tail -5
```

### **Question Sequence for k8s-agent:**

**Configuration:** Use **OpenAI GPT-4o** (rapid assessment)

1. **"What is the current health status of my cluster? Focus on the sre-companion-demo namespace"**
   - *Expected: Quick assessment of pods, deployments, services*

2. **"Analyze the resource configuration (CPU/memory) of my blue and green deployments. Are they optimized?"**
   - *Expected: Analysis of resource requests/limits*

3. **"Are there any potential issues you can identify in the current configuration?"**
   - *Expected: Issue identification like green deployment with 0 replicas*

**Switch to Anthropic Claude Sonnet 4:**

4. **"Based on the current configuration, design a capacity planning strategy for the next 6 months"**
   - *Expected: Strategic analysis and long-term recommendations*

5. **"What security improvements would you recommend for this blue/green deployment configuration?"**
   - *Expected: Detailed hardening recommendations*

---

## **Exercise 2: Load Testing Implementation with sre-companion**

### **Objective:** Demonstrate your custom agent capabilities under load

### **Command Script:**
```bash
# Execute light load test
./scripts/load-test.sh 60 50 200

# Monitor in parallel while test runs
kubectl top pods -n sre-companion-demo --no-headers=true
```

### **Question Sequence for sre-companion:**

**Configuration:** Use **OpenAI GPT-4o** (rapid operational response)

1. **"I'm running a load test. What is the current state of my blue/green deployment during the load?"**
   - *Expected: Real-time status assessment*

2. **"Are the pods handling the load well? Should I scale?"**
   - *Expected: Immediate scaling recommendations*

### **Intensify the Load:**
```bash
# More aggressive load test
./scripts/load-test.sh 120 150 500
```

3. **"Analyze the system behavior with this more intense load. Is there any degradation?"**
   - *Expected: Performance impact analysis*

**Switch to Anthropic Claude Sonnet 4:**

4. **"Based on the behavior observed during the load tests, what patterns do you identify and what optimization strategies would you recommend?"**
   - *Expected: Deep pattern analysis and strategy*

5. **"Design a complete load testing and capacity planning framework for this type of application"**
   - *Expected: Comprehensive methodological framework*

---

## **Exercise 3: Failure Simulation and Recovery Analysis**

### **Objective:** Demonstrate chaos engineering and incident response

### **Command Script:**
```bash
# Simulate immediate failure (pod deletion)
./scripts/simulate-failure.sh blue

# Observe recovery in real-time
kubectl get pods -n sre-companion-demo -w
# Ctrl+C after seeing recovery
```

### **Question Sequence for sre-companion:**

**Configuration:** Use **OpenAI GPT-4o** (incident response)

1. **"I just simulated a failure in the blue deployment. What's happening with the automatic failover?"**
   - *Expected: Immediate incident assessment*

2. **"How long did the recovery take? Does this meet typical SLAs?"**
   - *Expected: MTTR analysis*

### **More Complex Controlled Failure:**
```bash
# Simulate controlled outage
./scripts/simulate-failure.sh blue --outage 30

# While in outage, verify failover
kubectl get service web -n sre-companion-demo -o yaml | grep -A 5 selector
```

3. **"During this controlled outage, did the automatic controller activate failover? Was it effective?"**
   - *Expected: Analysis of automatic failover behavior*

**Switch to Anthropic Claude Sonnet 4:**

4. **"Analyze the entire incident event sequence. What improvements would you recommend to the failover process?"**
   - *Expected: Detailed RCA and recommendations*

5. **"Design a complete incident response playbook for this type of failures in production"**
   - *Expected: Comprehensive playbook with procedures*

---

## **Exercise 4: Query Generation with promql-agent**

### **Objective:** Demonstrate query generation and analysis capabilities

### **Command Script:**
```bash
# Generate some activity to have metrics
./scripts/load-test.sh 90 100 300 &
sleep 30

# Verify available metrics
curl -s http://localhost:9090/api/v1/label/__name__/values | jq -r '.data[]' | grep -i "kube_deployment"
```

### **Question Sequence for promql-agent:**

**Configuration:** Use **OpenAI GPT-4o** (rapid query generation)

1. **"Generate a PromQL query to show the number of available vs desired replicas for my blue/green deployments"**
   - *Expected: Specific query for replica monitoring*

2. **"I need a query to alert when CPU usage of any pod exceeds 80% for 5 minutes"**
   - *Expected: PromQL alerting rule*

3. **"Create a query to show HTTP request rate per second during the last 15 minutes"**
   - *Expected: Rate calculation query*

**Switch to Anthropic Claude Sonnet 4:**

4. **"Design a complete set of PromQL queries for comprehensive blue/green deployment monitoring, including critical SLIs"**
   - *Expected: Complete monitoring query suite*

5. **"Explain how you would structure an observability framework based on the queries you generated"**
   - *Expected: Observability strategy framework*

---

## **Exercise 5: Cascade Failure Scenario**

### **Objective:** Demonstrate complex incident handling

### **Command Script:**
```bash
# Create cascade failure scenario
./scripts/load-test.sh 180 200 600 &
sleep 60

# Blue failure while under load
./scripts/simulate-failure.sh blue --outage 45

# After 20s, green also fails
sleep 20
./scripts/simulate-failure.sh green --outage 30
```

### **Multi-Agent Question Sequence:**

**k8s-agent with OpenAI GPT-4o:**
1. **"I have an incident! Both blue and green deployments are failing under load. What's the immediate assessment?"**

**sre-companion with OpenAI GPT-4o:**
2. **"What immediate mitigation actions do you recommend for this cascade failure?"**

**observability-agent with Anthropic Claude Sonnet 4:**
3. **"Analyze the patterns of this cascade incident. What metrics should we have monitored to prevent this?"**

**k8s-agent with Anthropic Claude Sonnet 4:**
4. **"Design a recovery and prevention plan to avoid this type of cascade failures in the future"**

---

## **Exercise 6: Observability and Metrics Analysis**

### **Objective:** Demonstrate advanced monitoring data analysis

### **Command Script:**
```bash
# Check failover controller logs
kubectl logs deployment/failover-controller -n sre-companion-demo --tail=20

# Review recent events
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp'

# Verify endpoint status
kubectl get endpoints -n sre-companion-demo
```

### **Question Sequence for observability-agent:**

**Configuration:** Use **OpenAI GPT-4o** (rapid metrics interpretation)

1. **"Analyze the recent failover controller logs. Are there concerning patterns?"**
   - *Expected: Log analysis and pattern identification*

2. **"What metrics are available for monitoring my blue/green deployments?"**
   - *Expected: Available metrics inventory*

3. **"What are the gaps in my current observability stack?"**
   - *Expected: Immediate gap analysis*

**Switch to Anthropic Claude Sonnet 4:**

4. **"Design a complete observability strategy for a production environment with blue/green deployments"**
   - *Expected: Comprehensive observability strategy*

5. **"How would you implement SLOs and error budgets for this type of setup?"**
   - *Expected: Detailed SLO framework*

---

## **Exercise 7: Helm Management and Package Operations**

### **Objective:** Demonstrate package management and dependencies

### **Command Script:**
```bash
# Verify current releases
helm list -A

# See available prometheus charts
helm search repo prometheus-community | head -10
```

### **Question Sequence for helm-agent:**

**Configuration:** Use **OpenAI GPT-4o** (rapid package operations)

1. **"What Helm releases are currently installed in my cluster?"**
   - *Expected: Helm releases inventory*

2. **"How can I safely update my Prometheus stack to the latest version?"**
   - *Expected: Immediate upgrade strategy*

3. **"If I need to rollback the monitoring stack, what would be the process?"**
   - *Expected: Rollback procedure*

**Switch to Anthropic Claude Sonnet 4:**

4. **"Design a lifecycle management strategy for Helm charts in an enterprise environment"**
   - *Expected: Enterprise helm strategy*

5. **"How would you structure a CI/CD process for chart deployment with proper testing?"**
   - *Expected: CI/CD framework for helm*

---

## **Exercise 8: Final Comparative Analysis**

### **Objective:** Demonstrate dual-provider approach value

### **Command Script:**
```bash
# Final system state
kubectl get all -n sre-companion-demo
kubectl get events -n sre-companion-demo --sort-by='.lastTimestamp' | tail -10

# Verify services are healthy
curl -s http://localhost:8082/healthz
```

### **Identical Question to Multiple Agents:**

**Ask this question to ALL available agents, alternating between providers:**

**"Based on all the activity we've performed during this demo (load tests, failures, recovery), what are the 3 most important recommendations to improve this system's reliability?"**

**Sequence:**
1. `sre-companion` with **OpenAI GPT-4o**
2. `sre-companion` with **Anthropic Claude Sonnet 4**
3. `k8s-agent` with **OpenAI GPT-4o**
4. `k8s-agent` with **Anthropic Claude Sonnet 4**
5. `observability-agent` with **OpenAI GPT-4o**
6. `observability-agent` with **Anthropic Claude Sonnet 4**

### **Results Analysis:**
- Compare approach differences between providers
- Identify consistencies between specialized agents
- Show how different AI models reason about the same data

---

## **Post-Demo Cleanup Commands**

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

## **Key Points for Presentation**

### **Technical Highlights:**
- **11 specialized agents** working collaboratively
- **Dual-provider AI** showing different reasoning approaches
- **Real-time operations** with actual infrastructure
- **Production-ready patterns** in a demo environment

### **Observable Differences Between Providers:**
- **OpenAI GPT-4o**: Faster responses, focus on immediate actions
- **Anthropic Claude Sonnet 4**: Deeper analysis, strategic planning

### **Value Propositions:**
- **Reduced MTTR** through AI-assisted diagnosis
- **Consistent operations** across team members
- **Learning acceleration** for junior SREs
- **24/7 operational intelligence** without human fatigue