#Main terraform file for deploying GKE

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
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "location" {
  description = "location"
}

variable "sa_email" {
  description = "Service account email address"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "nodes" {
  default = 1
}

variable "machine_type" {
  default = "e2-standard-2"
}

variable "subdomain" {
  description = "****.dsp.garvan.org.au"
}

variable "env" {
  description = "Name of environment to deploy"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}