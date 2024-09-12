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
    prefix = "datahub-dev"
  }
}

module "base" {
    source = "../base"

    project_id = "garvan-data-hub-dev"
    region     = "australia-southeast1"
    location = "australia-southeast1-a"
    sa_email = "datahub-sa@garvan-data-hub-dev.iam.gserviceaccount.com"
    env = "dev"
    subdomain = "ckan.dsp"
    nodes = 1
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
  config_path = "~/.kube/datahub-dev.yml"
  config_context = "default"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/datahub-dev.yml"
    config_context = "default"
  }
}

provider "kubectl" {
  config_path = "~/.kube/datahub-dev.yml"
  config_context = "default"
}

resource "google_dns_record_set" "ckan" {

  name = "ckan.dsp.garvan.org.au."
  type = "A"
  ttl  = 300

  managed_zone = "dsp"
  project = "ctrl-358804"

  rrdatas = ["10.214.132.51"]
}