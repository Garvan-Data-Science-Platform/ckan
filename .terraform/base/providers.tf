provider "kubernetes" {
  #host = google_container_cluster.primary.endpoint
 
  #token                  = data.google_client_config.default.access_token
  #cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  config_path = "./k3s-config.yml"
  config_context = "default"
}

provider "helm" {
  kubernetes {
    #host = google_container_cluster.primary.endpoint
    #token                  = data.google_client_config.default.access_token
    #cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    config_path = "./k3s-config.yml"
    config_context = "default"
  }
}