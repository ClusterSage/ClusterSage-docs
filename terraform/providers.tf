terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "kubernetes" {
  host                   = module.app_hosting.kube_config_host
  client_certificate     = base64decode(module.app_hosting.kube_config_client_certificate)
  client_key             = base64decode(module.app_hosting.kube_config_client_key)
  cluster_ca_certificate = base64decode(module.app_hosting.kube_config_cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.app_hosting.kube_config_host
    client_certificate     = base64decode(module.app_hosting.kube_config_client_certificate)
    client_key             = base64decode(module.app_hosting.kube_config_client_key)
    cluster_ca_certificate = base64decode(module.app_hosting.kube_config_cluster_ca_certificate)
  }
}
