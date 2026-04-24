# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Kubernetes infrastructure-as-code project for local development of the **onlineorder2** application. It uses **Minikube** as the local K8s cluster and contains manifests for PostgreSQL and Nginx.

## Starting the Stack

```bash
# Start Minikube + deploy Postgres + set up port-forward (localhost:5432 → postgres pod)
./start.sh
```

The script logs all output to `start-postgres-k8s.log`.

## Applying Manifests Manually

```bash
kubectl apply -f postgres.yaml
kubectl apply -f nginx-deployment.yaml

# Check pod status
kubectl get pods
kubectl get pvc
kubectl get services
```

## Architecture

- **postgres.yaml** — Four K8s resources bundled together: a `Secret` (credentials), a `PersistentVolumeClaim` (`onlineorder2-pg-pvc`, 1Gi), a `Deployment` (postgres:15.2-alpine, 1 replica), and a `ClusterIP` Service on port 5432. The deployment mounts the PVC at `/var/lib/postgresql/data` and pulls credentials from the Secret.
- **nginx-deployment.yaml** — Standalone Nginx deployment (2 replicas, port 80). Currently has no associated Service or Ingress and is not connected to Postgres.
- **start.sh** — Idempotent bootstrap script: checks/starts Minikube, applies `postgres.yaml`, waits for pod readiness, then starts a background `kubectl port-forward` so the local app can reach Postgres at `localhost:5432`.

## Database Connection (local)

After running `start.sh`, Postgres is reachable at:

```
host=localhost port=5432 user=postgres password=secret dbname=onlineorder2
```
