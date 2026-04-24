#!/bin/bash

LOG="$HOME/app/k8s/start-postgres-k8s.log"
echo "$(date) — Starting..." >> "$LOG"

# Start minikube if not already running
STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null)
if [ "$STATUS" != "Running" ]; then
  echo "$(date) — Starting minikube..." >> "$LOG"
  minikube start >> "$LOG" 2>&1
else
  echo "$(date) — Minikube already running" >> "$LOG"
fi

# Wait for cluster to be ready
kubectl wait --for=condition=Ready node --all --timeout=120s >> "$LOG" 2>&1

# Apply postgres manifest
echo "$(date) — Applying postgres.yaml..." >> "$LOG"
kubectl apply -f "$HOME/app/k8s/postgres.yaml" >> "$LOG" 2>&1

# Wait for postgres pod to be ready
kubectl wait --for=condition=Ready pod -l app=postgres --timeout=120s >> "$LOG" 2>&1

echo "$(date) — Done. Postgres is running." >> "$LOG"
# Kill any existing port-forward first
pkill -f "kubectl port-forward service/postgres" 2>/dev/null

# Start port-forward in background
echo "$(date) — Starting port-forward..." >> "$LOG"
nohup kubectl port-forward service/postgres 5432:5432 >> "$LOG" 2>&1 &

echo "$(date) — postgres available at localhost:5432" >> "$LOG"
