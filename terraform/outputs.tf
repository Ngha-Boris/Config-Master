# Terraform Outputs

output "environment" {
  description = "Current environment (workspace)"
  value       = terraform.workspace
}

output "namespace" {
  description = "Kubernetes namespace name"
  value       = kubernetes_namespace.app_namespace.metadata[0].name
}

output "app_env_value" {
  description = "APP_ENV value from ConfigMap"
  value       = kubernetes_config_map.app_config.data["APP_ENV"]
}

output "deployment_name" {
  description = "Kubernetes deployment name"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  description = "Kubernetes service name"
  value       = kubernetes_service.app_service.metadata[0].name
}

output "service_type" {
  description = "Kubernetes service type"
  value       = kubernetes_service.app_service.spec[0].type
}

output "replicas" {
  description = "Number of replicas"
  value       = kubernetes_deployment.app.spec[0].replicas
}
