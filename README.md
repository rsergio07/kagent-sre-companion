# SRE Companion Demo: AI-Powered Operations with Kagent

This repository demonstrates how **Kagent** transforms traditional Site Reliability Engineering (SRE) practices through **AI-powered cluster operations**.

The demo showcases:

* Intelligent **blue/green deployment management**.
* Autonomous **failover capabilities**.
* Conversational **cluster operations with AI agents**.
* Integration of monitoring, load testing, and failure simulation into a cohesive scenario.

Rather than just showing perfect workflows, this demo also highlights **limitations** — such as incomplete metrics, rate limits, and service misconfigurations — turning them into **teachable moments** for real-world SRE practices.

---

## Table of Contents

- [Quick Deployment](#quick-deployment)
- [Architecture Overview](#architecture-overview)
- [Configuration Files](#configuration-files)
- [Load Testing Scenarios](#load-testing-scenarios)
- [Interactive Demo Framework](#interactive-demo-framework)
- [AI-Powered Operations](#ai-powered-operations)
- [SRE Principles](#sre-principles)
- [Validation Commands](#validation-commands)
- [Troubleshooting](#troubleshooting)
- [Known Demo Limitations](#known-demo-limitations)

---

## Quick Deployment

### Prerequisites

```bash
# Required tools
kubectl, helm, minikube, docker

# Set Anthropic or OpenAI API key
export ANTHROPIC_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"
```

Clone repository:

```bash
git clone https://github.com/rsergio07/kagent-sre-companion
cd kagent-sre-companion
```

### Setup

```bash
# Deploy the complete environment (10–15 minutes)
./scripts/setup-sre-companion.sh
```

This script provisions:

* Blue/green demo app
* Monitoring stack (Prometheus, Grafana)
* Autonomous failover controller
* Kagent AI platform with agent integrations

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

---

### Port Cleanup & Checks

Sometimes ports remain bound after closing terminals or killing `kubectl port-forward`.
Use the following command to check all relevant ports (8082, 8081, 3000, 9090):

```bash
lsof -i :8082 -i :8081 -i :3000 -i :9090
```

To kill any process bound to these ports (⚠️ use with caution):

```bash
kill -9 <PID>
```

---

## Architecture Overview

* **App Layer**: Flask service with `/healthz`, `/readyz`, `/work` endpoints and blue/green theming.
* **Blue/Green Deployments**: Service routing with selectors (`version=blue` / `version=green`).
* **Failover Controller**: Monitors deployments and switches traffic automatically.
* **Kagent + AI**: Conversational interface powered by Claude/OpenAI models.
* **Monitoring Stack**: Prometheus + Grafana with failover and workload dashboards.

---

## Configuration Files

* `app/`: Flask app, Dockerfile, templates.
* `k8s/`: Namespace, deployments, and service YAMLs.
* `controllers/`: Failover controller spec.
* `kagent/`: Model configs, MCP server, agent configs.
* `scripts/`: Setup, cleanup, load testing, and failure simulation.

---

## Load Testing Scenarios

Controlled load is generated with `scripts/load-test.sh`.

Examples:

```bash
# Baseline (120s, 150 concurrency, 500ms CPU burn)
./scripts/load-test.sh

# Traffic spike (120s, 300 concurrency, 800ms work)
./scripts/load-test.sh 120 300 800

# Sustained failover test (240s, 100 concurrency, 400ms work)
./scripts/load-test.sh 240 100 400
```

Purpose: populate Grafana dashboards, trigger HPAs, and showcase failover automation.

---

## Interactive Demo Framework

### Phase 1: Cluster Awareness

* `kubectl get pods -n sre-companion-demo`
* Ask AI: *“What is the current state of my blue/green deployment?”*

### Phase 2: Failover

* Force outage: `kubectl scale deployment web-blue --replicas=0 -n sre-companion-demo`
* Or simulate: `./scripts/simulate-failure.sh blue --outage 30`

AI Prompt: *“Did a failover event occur just now? Show me the details.”*

### Phase 3: Load & Scaling

* `./scripts/load-test.sh 300 200 1000`
* AI Prompt: *“How are the deployment pods performing under stress?”*

### Phase 4: Root Cause Analysis

* `kubectl logs deployment/failover-controller -n sre-companion-demo`
* AI Prompt: *“Correlate failover-controller events with CPU metrics.”*

### Phase 5: Strategic Recommendations

* AI Prompt: *“Suggest improvements to reduce failover time and improve probes.”*

---

## AI-Powered Operations

* **Cluster analysis**: service health, deployment states, failover suggestions.
* **Scaling**: create HPAs and monitor autoscaling events.
* **Failure diagnosis**: analyze pod restarts, probe failures, controller events.
* **Strategic advice**: probe tuning, autoscaling policies, service mesh recommendations.

---

## SRE Principles

* **Observability**: AI queries unify Prometheus + logs → human-friendly summaries.
* **Automation**: Failover controller reduces MTTR by auto-switching traffic.
* **Resilience Testing**: Failure simulation + AI analysis = democratized chaos engineering.
* **Knowledge Sharing**: Conversational AI makes SRE expertise more accessible.

---

## Validation Commands

```bash
# Pods & deployments
kubectl get deployments,pods -n sre-companion-demo -l app=web

# Service routing
kubectl describe svc web -n sre-companion-demo
kubectl get endpoints web -n sre-companion-demo

# HPA
kubectl get hpa -n sre-companion-demo
kubectl describe hpa web-blue-hpa -n sre-companion-demo
```

---

## Troubleshooting

* **API Key issues**: check Anthropic/OpenAI secrets in `kagent` namespace.
* **Port forwarding lost**: just rerun the port-forward command (no redeploy needed).
* **Metrics missing**: app not instrumented with Prometheus → queries return empty.
* **Resource constraints**: increase Minikube CPU/RAM if pods stay pending.

---

## Known Demo Limitations

This demo intentionally exposes **AI limitations** for educational value:

* **Model versioning**: Anthropic requires exact model IDs (e.g., `claude-sonnet-4-20250514`).
* **Rate limits**: Hitting Anthropic token limits interrupts agent workflows.
* **Metric gaps**: The demo app isn’t fully instrumented for Prometheus → error/latency queries return empty.
* **Service misrouting**: By default, the service may point to `green=0 pods` → outage scenario.
* **Human validation required**: AI recommendations (e.g., HPA creation) may silently fail if deployments lack resource limits.

👉 These “failures” are part of the demo — they show why **AI augments but doesn’t replace human SRE judgment**.

---

![Kubernetes SRE AI-Powered](https://img.shields.io/badge/Kubernetes-SRE%20AI--Powered-blue)