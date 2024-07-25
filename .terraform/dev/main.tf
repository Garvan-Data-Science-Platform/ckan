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
  }
  backend "gcs" {
    bucket = "terraform-state-ckan"
    prefix = "dev"
  }
}

module "base" {
    source = "../base"

    project_id = "garvan-data-hub-dev"
    region     = "australia-southeast1"
    location = "australia-southeast1-a"
    sa_email = "datahub-sa@garvan-data-hub-dev.iam.gserviceaccount.com"
    env = "dev"
    subdomain = "ckan-dev"
    nodes = 1
}

output "kubernetes_cluster_name" {
  value       = module.base.kubernetes_cluster_name
  description = "GKE Cluster Name"
}

provider "google" {
  project = module.base.project_id
  region  = module.base.region
}

provider "google-beta" {
  project = module.base.project_id
  region  = module.base.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host = module.base.kubernetes_cluster_host
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = module.base.cluster_ca
}

provider "helm" {
  kubernetes {
    host = module.base.kubernetes_cluster_host
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = module.base.cluster_ca
  }
}