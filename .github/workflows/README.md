# CI/CD Pipeline Documentation

## Overview

This GitHub Actions workflow implements a complete CI/CD pipeline with:
- **Automatic staging deployment** on every push
- **Manual approval gate** for production
- **Terraform workspaces** for environment separation

## Pipeline Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐     ┌──────────────────┐
│   Push to   │────▶│    Build    │────▶│  Deploy to      │────▶│  Deploy to       │
│   main      │     │  & Test     │     │  Staging        │     │  Production      │
│             │     │             │     │  (Automatic)    │     │  (Manual Approve)│
└─────────────┘     └─────────────┘     └─────────────────┘     └──────────────────┘
                                              │                           │
                                              ▼                           ▼
                                        ┌──────────┐              ┌──────────┐
                                        │ BLUE UI  │              │ RED UI   │
                                        │ Staging  │              │Production│
                                        └──────────┘              └──────────┘
```

## Workflow Jobs

### 1. Build & Test (`build`)
- Builds Docker image
- Tests that staging shows BLUE UI
- Saves image as artifact

### 2. Deploy to Staging (`deploy-staging`)
- **Trigger**: Automatic (after build succeeds)
- **Environment**: `staging`
- Uses Terraform workspace: `staging`
- Deploys with: `APP_ENV=staging` → **BLUE UI**

### 3. Deploy to Production (`deploy-production`)
- **Trigger**: Manual approval required
- **Environment**: `production`
- Uses Terraform workspace: `production`
- Deploys with: `APP_ENV=production` → **RED UI**

## GitHub Environment Configuration

### Step 1: Create Environments

Go to **Settings → Environments → New environment**

#### Staging Environment
- Name: `staging`
- Protection rules: (optional) Add required reviewers if desired
- Deployment branches: `main`, `master`

#### Production Environment
- Name: `production`
- **Required reviewers**: Enable and add reviewers (for manual approval)
- Deployment branches: `main`, `master`
- (Optional) Add deployment protection rules

### Step 2: Configure Secrets (if needed)

If deploying to external Kubernetes:

```
Settings → Secrets and variables → Actions → New repository secret
```

- `KUBECONFIG`: Base64 encoded kubeconfig file
- `TF_API_TOKEN`: Terraform Cloud token (if using remote backend)

## Terraform Workspaces

The pipeline uses Terraform workspaces to separate environments:

```bash
# Staging workspace
terraform workspace select staging
terraform apply  # Creates staging namespace, ConfigMap with APP_ENV=staging

# Production workspace
terraform workspace select production
terraform apply  # Creates production namespace, ConfigMap with APP_ENV=production
```

### Workspace Isolation

| Workspace | Namespace | APP_ENV | Replicas | UI Color |
|-----------|-----------|---------|----------|----------|
| staging | staging | staging | 1 | 🔵 Blue |
| production | production | production | 2 | 🔴 Red |

## Usage

### Automatic Staging Deployment

Every push to `main` branch automatically deploys to staging:

```bash
git push origin main
# → Pipeline runs
# → Deploys to staging automatically
# → Shows BLUE UI
```

### Production Deployment with Approval

1. Push code (staging deploys automatically)
2. Go to **Actions** tab
3. Find the running workflow
4. Click **Review deployments**
5. Click **Approve and deploy**
6. Production deploys with **RED UI**

## Local Testing

```bash
# Test the workflow locally with act (https://github.com/nektos/act)
act -j build

# Test staging deployment
act -j deploy-staging --secret-file .secrets
```

## Pipeline Features

✅ **Build caching** with Docker layer cache  
✅ **Artifact passing** between jobs  
✅ **Terraform state isolation** per workspace  
✅ **Health checks** before marking deployment complete  
✅ **Environment URLs** for quick access  
✅ **Manual approval gate** for production safety  

## Troubleshooting

### Issue: "Environment not found"
**Solution**: Create the environments in GitHub Settings first

### Issue: "Terraform workspace not found"
**Solution**: The workflow auto-creates workspaces with `|| terraform workspace new`

### Issue: "Image pull errors"
**Solution**: Update `imagePullPolicy` to `Always` for external registries
