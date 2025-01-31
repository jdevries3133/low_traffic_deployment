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

data "external" "git_describe" {
  program = ["sh", "scripts/git_describe.sh"]
}

module "low_traffic_deployment" {
  source = "../"
  container = "jdevries3133/low_traffic_demo_app:v3.1.0"
  app_name = "ltd"
  domain = "ltdemo.jackdevries.com"
}
