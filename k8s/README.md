# Kubernetes Deployment Guide

This directory contains all Kubernetes manifests for deploying the Config Master App to separate staging and production environments.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Kubernetes Cluster                        │
│  ┌─────────────────────┐    ┌─────────────────────┐          │
│  │   staging NS        │    │   production NS     │          │
│  │  ┌───────────────┐  │    │  ┌───────────────┐  │          │
│  │  │ ConfigMap     │  │    │  │ ConfigMap     │  │          │
│  │  │ APP_ENV=staging│  │    │  │ APP_ENV=prod  │  │          │
│  │  └───────┬───────┘  │    │  └───────┬───────┘  │          │
│  │          │          │    │          │          │          │
│  │  ┌───────▼───────┐  │    │  ┌───────▼───────┐  │          │
│  │  │   Deployment  │  │    │  │   Deployment  │  │          │
│  │  │   (1 replica) │  │    │  │   (1 replica) │  │          │
│  │  │  ┌─────────┐  │  │    │  │  ┌─────────┐  │  │          │
│  │  │  │  Pod    │  │  │    │  │  │  Pod    │  │  │          │
│  │  │  │ (Blue)  │  │  │    │  │  │  (Red)  │  │  │          │
│  │  │  └────┬────┘  │  │    │  │  └────┬────┘  │  │          │
│  │  └───────┼───────┘  │    │  └───────┼───────┘  │          │
│  │          │          │    │          │          │          │
│  │  ┌───────▼───────┐  │    │  ┌───────▼───────┐  │          │
│  │  │    Service    │  │    │  │    Service    │  │          │
│  │  │   NodePort    │  │    │  │   NodePort    │  │          │
│  │  └───────────────┘  │    │  └───────────────┘  │          │
│  └─────────────────────┘    └─────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Files Description

| File | Purpose |
|------|---------|
| `namespace-staging.yaml` | Creates the `staging` namespace |
| `namespace-production.yaml` | Creates the `production` namespace |
| `configmap-staging.yaml` | ConfigMap with `APP_ENV=staging` (blue) |
| `configmap-production.yaml` | ConfigMap with `APP_ENV=production` (red) |
| `deployment-staging.yaml` | Deployment + Service for staging |
| `deployment-production.yaml` | Deployment + Service for production |
| `kustomization.yaml` | Kustomize configuration for combined deployment |

## Key Design Principles

### 1. Namespace Isolation
- **staging** namespace: For development/testing
- **production** namespace: For live application
- Each namespace has its own isolated resources

### 2. ConfigMap-Driven Configuration
Environment variables are injected via ConfigMaps:

```yaml
# Staging ConfigMap
APP_ENV: "staging"  # Results in BLUE UI

# Production ConfigMap  
APP_ENV: "production"  # Results in RED UI
```

The application reads `APP_ENV` and changes its UI color accordingly:
- `staging` → Blue (#0d6efd)
- `production` → Red (#dc3545)

### 3. No Code Changes Required
The **same Docker image** is used in both environments. Only the ConfigMap changes.

## Deployment Instructions

### Option 1: Apply All at Once (using Kustomize)

```bash
# Deploy everything
kubectl apply -k k8s/
```

### Option 2: Apply Individually

```bash
# 1. Create namespaces
kubectl apply -f k8s/namespace-staging.yaml
kubectl apply -f k8s/namespace-production.yaml

# 2. Create ConfigMaps
kubectl apply -f k8s/configmap-staging.yaml
kubectl apply -f k8s/configmap-production.yaml

# 3. Deploy applications
kubectl apply -f k8s/deployment-staging.yaml
kubectl apply -f k8s/deployment-production.yaml
```

## Verification Commands

```bash
# Check namespaces
kubectl get namespaces

# Check pods in staging
kubectl get pods -n staging

# Check pods in production
kubectl get pods -n production

# View staging app logs
kubectl logs -n staging -l app=config-master-app

# View production app logs
kubectl logs -n production -l app=config-master-app

# Check services
kubectl get services -n staging
kubectl get services -n production

# Port-forward to test staging locally
kubectl port-forward -n staging svc/config-master-app-service 8080:80

# Port-forward to test production locally
kubectl port-forward -n production svc/config-master-app-service 8081:80
```

## Accessing the Applications

### Using NodePort (if cluster supports it)

```bash
# Get NodePort for staging
kubectl get svc -n staging config-master-app-service

# Get NodePort for production
kubectl get svc -n production config-master-app-service
```

### Using Port-Forward (local testing)

```bash
# Staging (will be BLUE)
kubectl port-forward -n staging svc/config-master-app-service 3000:80
# Open http://localhost:3000

# Production (will be RED)
kubectl port-forward -n production svc/config-master-app-service 3001:80
# Open http://localhost:3001
```

## Expected Results

| Environment | URL | Expected Color | Badge Text |
|-------------|-----|----------------|------------|
| Staging | http://localhost:3000 | 🔵 Blue | "Staging Environment" |
| Production | http://localhost:3001 | 🔴 Red | "Production Environment" |

## Cleanup

```bash
# Remove all resources
kubectl delete -k k8s/

# Or remove by namespace (removes everything in namespace)
kubectl delete namespace staging
kubectl delete namespace production
```

## Notes for Production Use

1. **Image Registry**: Update `image: config-master-app:latest` to point to your container registry (ECR, Docker Hub, etc.)
   ```yaml
   image: your-registry/config-master-app:v1.0.0
   imagePullPolicy: Always
   ```

2. **Ingress**: For production, add Ingress resources instead of NodePort services

3. **Scaling**: Increase `replicas` in Deployment for high availability

4. **Secrets**: Use Kubernetes Secrets for sensitive data (if needed)

5. **Resource Limits**: Adjust CPU/memory based on actual usage

