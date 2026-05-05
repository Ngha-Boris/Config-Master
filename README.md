# Config-Master

A complete DevOps project demonstrating environment promotion with Kubernetes, Terraform, and GitHub Actions.

> **One codebase, multiple environments** — Staging and Production

## Project Overview

This project demonstrates professional DevOps practices including:
- Environment-based application behavior (Blue for Staging, Red for Production)
- Kubernetes ConfigMaps and Namespaces for environment isolation
- Terraform Workspaces for infrastructure separation
- GitHub Actions with manual approval gates for production deployments

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GitHub Actions Pipeline                           │
│  ┌─────────┐    ┌─────────┐    ┌──────────────┐    ┌──────────────────────┐ │
│  │  Push   │───▶│  Build  │───▶│   Staging    │───▶│  Production          │ │
│  │  main   │    │  Image  │    │  (Automatic) │    │  (Manual Approve)    │ │
│  └─────────┘    └─────────┘    └──────┬───────┘    └──────────┬───────────┘ │
│                                       │                       │             │
└───────────────────────────────────────┼───────────────────────┼─────────────┘
                                        │                       │
                                        ▼                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Kubernetes Cluster                                   │
│  ┌─────────────────────────┐    ┌─────────────────────────┐                 │
│  │   staging Namespace     │    │   production Namespace  │                 │
│  │  ┌─────────────────┐    │    │  ┌─────────────────┐    │                 │
│  │  │  ConfigMap      │    │    │  │  ConfigMap      │    │                 │
│  │  │  APP_ENV=staging│    │    │  │  APP_ENV=prod   │    │                 │
│  │  └────────┬────────┘    │    │  └────────┬────────┘    │                 │
│  │           │             │    │           │             │                 │
│  │  ┌────────▼────────┐    │    │  ┌────────▼────────┐    │                 │
│  │  │   Deployment    │    │    │  │   Deployment    │    │                 │
│  │  │   (1 replica)   │    │    │  │   (2 replicas)  │    │                 │
│  │  │   🔵 BLUE UI    │    │    │  │   🔴 RED UI     │    │                 │
│  │  └─────────────────┘    │    │  └─────────────────┘    │                 │
│  └─────────────────────────┘    └─────────────────────────┘                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
Config-Master/
├── .github/
│   └── workflows/
│       ├── cicd-pipeline.yml      # CI/CD with manual approval
│       └── README.md              # Pipeline documentation
├── k8s/
│   ├── namespace-staging.yaml     # Staging namespace
│   ├── namespace-production.yaml  # Production namespace
│   ├── configmap-staging.yaml     # Staging ConfigMap (APP_ENV=staging)
│   ├── configmap-production.yaml  # Production ConfigMap (APP_ENV=production)
│   ├── deployment-staging.yaml    # Staging deployment + service
│   ├── deployment-production.yaml # Production deployment + service
│   ├── kustomization.yaml         # Kustomize configuration
│   └── README.md                  # Kubernetes documentation
├── terraform/
│   ├── main.tf                    # Terraform resources
│   ├── variables.tf               # Terraform variables
│   ├── outputs.tf                 # Terraform outputs
│   └── README.md                  # Terraform documentation
├── views/
│   └── index.html                 # HTML template with placeholders
├── server.js                      # Node.js Express server
├── package.json                   # Node.js dependencies
├── Dockerfile                     # Docker image definition
├── .dockerignore                  # Docker ignore file
├── .gitignore                     # Git ignore file
└── README.md                      # This file
```

## Quick Start

### 1. Build and Run Locally

```bash
# Build Docker image
docker build -t config-master-app .

# Run staging (Blue UI)
docker run -d -p 3000:3000 -e APP_ENV=staging config-master-app

# Run production (Red UI)
docker run -d -p 3001:3000 -e APP_ENV=production config-master-app
```

### 2. Deploy to Kubernetes

```bash
# Deploy everything
kubectl apply -k k8s/

# Or deploy individually
kubectl apply -f k8s/namespace-staging.yaml
kubectl apply -f k8s/configmap-staging.yaml
kubectl apply -f k8s/deployment-staging.yaml
```

### 3. Deploy with Terraform

```bash
cd terraform

# Initialize
terraform init

# Deploy to staging
terraform workspace select staging || terraform workspace new staging
terraform apply

# Deploy to production
terraform workspace select production || terraform workspace new production
terraform apply
```

## Environment Behavior

| Environment | APP_ENV | ConfigMap | UI Color | Badge Text |
|-------------|---------|-----------|----------|------------|
| Staging | `staging` | `k8s/configmap-staging.yaml` | 🔵 Blue | "Staging Environment" |
| Production | `production` | `k8s/configmap-production.yaml` | 🔴 Red | "Production Environment" |

## CI/CD Pipeline

The GitHub Actions workflow (`cicd-pipeline.yml`) implements:

1. **Build & Test** - Builds Docker image and tests both environments
2. **Deploy to Staging** - Automatic deployment on every push to `main`
3. **Deploy to Production** - Requires manual approval in GitHub UI

### GitHub Environment Setup

1. Go to **Settings → Environments → New environment**
2. Create `staging` environment
3. Create `production` environment with **Required reviewers** enabled

## Technologies Used

- **Node.js / Express** - Web application framework
- **Docker** - Containerization
- **Kubernetes** - Container orchestration with ConfigMaps and Namespaces
- **Terraform** - Infrastructure as Code with workspaces
- **GitHub Actions** - CI/CD pipeline with manual approval gates

## Key DevOps Concepts Demonstrated

✅ **Environment Promotion** - Code moves from staging to production  
✅ **ConfigMaps** - Environment-specific configuration injection  
✅ **Namespaces** - Kubernetes resource isolation  
✅ **Terraform Workspaces** - Separate infrastructure state per environment  
✅ **Manual Approval Gates** - Human-in-the-loop for production deployments  

## Documentation

- [Kubernetes Deployment Guide](k8s/README.md)
- [Terraform Infrastructure](terraform/README.md)
- [CI/CD Pipeline](.github/workflows/README.md)

## License

MIT
