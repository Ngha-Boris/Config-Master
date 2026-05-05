# Terraform Configuration for Config Master App Infrastructure
# Uses workspaces to separate staging and production environments

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Local backend with workspace support
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

# Local variables based on workspace
locals {
  environment = terraform.workspace
  
  # Environment-specific configurations
  env_config = {
    staging = {
      namespace       = "staging"
      app_env         = "staging"
      replicas        = 1
      service_type    = "NodePort"
      resource_limits = {
        cpu    = "200m"
        memory = "128Mi"
      }
    }
    production = {
      namespace       = "production"
      app_env         = "production"
      replicas        = 2
      service_type    = "NodePort"
      resource_limits = {
        cpu    = "500m"
        memory = "256Mi"
      }
    }
  }
  
  current_env = local.env_config[local.environment]
}

# Kubernetes Namespace
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = local.current_env.namespace
    labels = {
      name        = local.current_env.namespace
      environment = local.environment
      managed_by  = "terraform"
    }
  }
}

# ConfigMap for environment variables
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }
  
  data = {
    APP_ENV = local.current_env.app_env
    PORT    = "3000"
  }
}

# Kubernetes Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "config-master-app"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app         = "config-master-app"
      environment = local.environment
    }
  }
  
  spec {
    replicas = local.current_env.replicas
    
    selector {
      match_labels = {
        app         = "config-master-app"
        environment = local.environment
      }
    }
    
    template {
      metadata {
        labels = {
          app         = "config-master-app"
          environment = local.environment
        }
      }
      
      spec {
        container {
          name  = "app"
          image = var.docker_image
          image_pull_policy = var.image_pull_policy
          
          port {
            container_port = 3000
          }
          
          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
          }
          
          resources {
            limits = {
              cpu    = local.current_env.resource_limits.cpu
              memory = local.current_env.resource_limits.memory
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }
      }
    }
  }
}

# Kubernetes Service
resource "kubernetes_service" "app_service" {
  metadata {
    name      = "config-master-app-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app         = "config-master-app"
      environment = local.environment
    }
  }
  
  spec {
    selector = {
      app         = "config-master-app"
      environment = local.environment
    }
    
    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }
    
    type = local.current_env.service_type
  }
}
