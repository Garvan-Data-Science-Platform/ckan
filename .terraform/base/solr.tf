resource "kubernetes_deployment" "solr" {
  metadata {
    name = "solr-${var.env}"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "solr-${var.env}"
      }
    }
    template {
      metadata {
        labels = {
          App = "solr-${var.env}"
        }
      }
      spec {

        init_container {
          name="volume-permissions"
          image="busybox"
          command=["/bin/sh"]
          args= ["-c", "adduser -D -u 8983 solr && chmod -R 755 /var/solr && chown solr /var/solr"]
          volume_mount {
            mount_path = "/var/solr"
            name = "solr-volume-mount"
            #sub_path = "redis"
          }
        }

        container {
          image = "ckan/ckan-solr:2.10-solr9"
          name  = "solr"
          port {
            container_port = 8983
          }
          volume_mount {
            mount_path = "/var/solr"
            name = "solr-volume-mount"
            #sub_path = "redis"
          }
        }
        volume {
            name = "solr-volume-mount"
            persistent_volume_claim {
                claim_name = "solr-claim"
            }
        }
      }

    }
  }
}

resource "google_compute_disk" "solr" {
  name  = "garvan-solr"
  type  = "pd-ssd"
  zone  = var.location
  #image = "debian-11-bullseye-v20220719"
  size = 20 #Gb
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}

resource "kubernetes_persistent_volume" "solr" {
  metadata {
    name = "solr-pv"
  }
  spec {
    capacity = {
      storage = "20Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.solr.name
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "solr" {
  metadata {
    name = "solr-claim"
    labels = {
        App = "solr-${var.env}"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}


resource "kubernetes_service" "solr" {
  
  metadata {
    annotations = {
      "cloud.google.com/neg": "{\"ingress\": true}",
    }
    name = "solr-${var.env}"
    labels = {
        App = "solr-${var.env}"
    }
  }
  spec {
    selector = {
      App = "solr-${var.env}" #This should match the kubernetes deployment
    }
    port {
      port = 8983
      target_port = 8983
    }

    type = "NodePort"
  }
}



