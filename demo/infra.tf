terraform {

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }

  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "low_traffic_deployment" {
  source = "../"
  container = "jdevries3133/low_traffic_demo_app:0.0.1"
  app_name = "demo-low-traffic"
  domain = "jackdevries.com"
}
