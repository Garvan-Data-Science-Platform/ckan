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
          image = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/solr"
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
        storage = "5Gi"
      }
    }
    storage_class_name = "local-path"
  }
}


resource "kubernetes_service" "solr" {
  
  metadata {

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



