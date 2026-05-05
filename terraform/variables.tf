# Terraform Variables

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = ""
}

variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "config-master-app:latest"
}

variable "image_pull_policy" {
  description = "Kubernetes image pull policy"
  type        = string
  default     = "IfNotPresent"
}
