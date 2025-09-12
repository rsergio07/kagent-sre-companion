#!/usr/bin/env bash
set -euo pipefail

# Simulate failure for a color (blue|green)
# Default: force-delete all pods (fast churn)
# Optional: --outage <seconds> scales to 0, waits, then restores (predictable failover)
#
# Usage:
#   ./scripts/simulate-failure.sh blue
#   ./scripts/simulate-failure.sh blue --outage 20
#   ./scripts/simulate-failure.sh green --outage 15
#
# Env:
#   NAMESPACE (default: sre-companion-demo)

NAMESPACE="${NAMESPACE:-sre-companion-demo}"

err() { echo "[x] $*" >&2; exit 1; }
info(){ echo "[+] $*"; }
note(){ echo "[i] $*"; }

[[ $# -ge 1 ]] || err "Usage: $0 <blue|green> [--outage <seconds>]"

COLOR="$1"; shift || true
[[ "$COLOR" == "blue" || "$COLOR" == "green" ]] || err "Color must be blue or green"

OUTAGE=""
if [[ "${1:-}" == "--outage" ]]; then
  shift
  OUTAGE="${1:-}"
  [[ -n "$OUTAGE" ]] || err "Please provide outage seconds after --outage"
  [[ "$OUTAGE" =~ ^[0-9]+$ ]] || err "Outage must be an integer number of seconds"
fi

DEPLOY="web-${COLOR}"

if [[ -n "$OUTAGE" ]]; then
  # Predictable outage: scale to 0, wait, restore
  # Capture current replicas (default to 1 if missing)
  CURRENT_REPLICAS="$(kubectl -n "$NAMESPACE" get deploy "$DEPLOY" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 1)"
  [[ -n "$CURRENT_REPLICAS" ]] || CURRENT_REPLICAS=1

  info "Simulating outage for $COLOR: scaling $DEPLOY to 0 replicas for ${OUTAGE}s (was ${CURRENT_REPLICAS})"
  kubectl -n "$NAMESPACE" scale deploy "$DEPLOY" --replicas=0

  note  "Waiting ${OUTAGE}s (watcher should flip Service if other color is healthy)"
  sleep "$OUTAGE"

  info "Restoring $DEPLOY to ${CURRENT_REPLICAS} replicas"
  kubectl -n "$NAMESPACE" scale deploy "$DEPLOY" --replicas="${CURRENT_REPLICAS}"

  note  "Waiting for pods to become Ready..."
  kubectl -n "$NAMESPACE" rollout status deploy/"$DEPLOY"
else
  # Legacy behavior: force delete pods to trigger self-heal
  info "Simulating failure: force-deleting pods for version=$COLOR"
  # List pods and delete them immediately (non-graceful) for a visible blip
  PODS=$(kubectl -n "$NAMESPACE" get pods -l "app=web,version=$COLOR" -o name)
  if [[ -z "$PODS" ]]; then
    note "No pods found for $COLOR. Nothing to delete."
    exit 0
  fi

  while IFS= read -r p; do
    kubectl -n "$NAMESPACE" delete "$p" --force --grace-period=0 || true
  done <<< "$PODS"

  note "Watch new pods come up (Ctrl+C to stop)"
  kubectl -n "$NAMESPACE" get pods -l "app=web" -w
fi