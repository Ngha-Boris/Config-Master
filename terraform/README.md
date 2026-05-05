# Terraform Infrastructure

This directory contains Terraform configuration for managing Kubernetes infrastructure across staging and production environments using workspaces.

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    Terraform Workspaces                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────┐    ┌─────────────────────┐         │
│  │   staging workspace │    │  production workspace│        │
│  │   (terraform.tfstate.d/staging/terraform.tfstate)│       │
│  ├─────────────────────┤    ├─────────────────────┤         │
│  │  • staging namespace│    │  • production namespace│        │
│  │  • APP_ENV=staging  │    │  • APP_ENV=production │        │
│  │  • 1 replica        │    │  • 2 replicas         │        │
│  │  • Lower resources  │    │  • Higher resources    │        │
│  └─────────────────────┘    └─────────────────────┘         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## File Structure

| File | Purpose |
|------|---------|
| `main.tf` | Main Terraform configuration with Kubernetes resources |
| `variables.tf` | Input variables |
| `outputs.tf` | Output values |
| `README.md` | This documentation |

## Resources Created

For each workspace, Terraform creates:

1. **Namespace** - Kubernetes namespace (staging/production)
2. **ConfigMap** - Environment configuration (APP_ENV value)
3. **Deployment** - Application deployment with configurable replicas
4. **Service** - NodePort service to expose the application

## Usage

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Create/Select Workspaces

```bash
# Create staging workspace
terraform workspace new staging

# Create production workspace
terraform workspace new production

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select staging
```

### Deploy to Staging

```bash
terraform workspace select staging
terraform plan -var="docker_image=config-master-app:latest"
terraform apply
```

### Deploy to Production

```bash
terraform workspace select production
terraform plan -var="docker_image=config-master-app:latest"
terraform apply
```

## Environment Differences

| Feature | Staging | Production |
|---------|---------|------------|
| Namespace | staging | production |
| APP_ENV | staging | production |
| Replicas | 1 | 2 |
| CPU Limit | 200m | 500m |
| Memory Limit | 128Mi | 256Mi |
| UI Color | 🔵 Blue | 🔴 Red |

## Outputs

After deployment, Terraform provides:

```bash
terraform output
# environment    = "staging" or "production"
# namespace      = "staging" or "production"
# app_env_value  = "staging" or "production"
# deployment_name = "config-master-app"
# service_name   = "config-master-app-service"
# replicas       = 1 or 2
```

## Cleanup

```bash
# Destroy staging
terraform workspace select staging
terraform destroy

# Destroy production
terraform workspace select production
terraform destroy
```

## Integration with CI/CD

The GitHub Actions workflow automatically:
1. Selects the appropriate workspace
2. Applies Terraform configuration
3. Verifies deployment outputs

See `.github/workflows/cicd-pipeline.yml` for details.
