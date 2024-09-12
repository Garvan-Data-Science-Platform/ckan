terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.5.0"
    }
    kubernetes = {
      source  = "hashicorp/helm"
      version = "2.5.1"
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
  backend "gcs" {
    bucket = "terraform-state-ckan"
    prefix = "prod-k3s"
  }
}

module "base" {
    source = "../base"
    project_id = "garvan-data-hub"
    region     = "australia-southeast1"
    location = "australia-southeast1-a"
    sa_email = "datahub-sa@garvan-data-hub.iam.gserviceaccount.com"
    env = "prod"
    subdomain = "datahub"
    nodes = 2
}


provider "google" {
  project = module.base.project_id
  region  = module.base.region
}

provider "google-beta" {
  project = module.base.project_id
  region  = module.base.region
}

provider "kubernetes" {
  config_path = "~/.kube/datahub-prod.yml"
  config_context = "default"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/datahub-prod.yml"
    config_context = "default"
  }
}

provider "kubectl" {
  config_path = "~/.kube/datahub-prod.yml"
  config_context = "default"
}