resource "kubernetes_deployment" "ckan" {
  metadata {
    name = "ckan-${var.env}"
  }

  depends_on = [helm_release.postgres]

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "ckan-${var.env}"
      }
    }

    template {
      metadata {
        labels = {
          App = "ckan-${var.env}"
        }
      }
      spec {

        node_selector = {
            "kubernetes.io/hostname": "k3s"
        }

        volume {
            name = "ckan-volume-mount"
            persistent_volume_claim {
                claim_name = "ckan-claim-2"
            }
        }

        image_pull_secrets {
          name="regcred"
        }

        container {
          image = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/ckan:mac"
          image_pull_policy = "Always"
          name  = "ckan"
          port {
            container_port = 8000
          }
          volume_mount {
            mount_path = "/var/lib/ckan/default"
            name = "ckan-volume-mount"
            #sub_path = "redis"
          }

          resources {
            limits = {
            cpu = 1
          }
        }

          command = ["./docker/entrypoint.sh"]

          env {
            name = "SITE_URL"
            value = "https://${var.subdomain}.dsp.garvan.org.au"
          }
          env {
            name = "SESS_KEY"
            value = data.google_secret_manager_secret_version.sess_key.secret_data
          }
          env {
            name = "SECRET_KEY"
            value = data.google_secret_manager_secret_version.secret_key.secret_data
          }
          env {
            name = "XLOADER_TOKEN"
            value = data.google_secret_manager_secret_version.xloader_token.secret_data
          }         
          env {
            name = "DB_PASS"
            value = data.google_secret_manager_secret_version.postgres_password.secret_data
          }
          env {
            name = "DB_HOST"
            value = "postgres-${var.env}-postgresql"
          }
          env {
            name = "ckan_HOST"
            value = "ckan-${var.env}"
          }
          env {
            name = "REDIS_HOST"
            value = "redis-${var.env}-master"
          }
          env {
            name = "SOLR_HOST"
            value = "solr-${var.env}"
          }
          env {
            name = "IDP_URL"
            value = data.google_secret_manager_secret_version.idp_url.secret_data
          }
          env {
            name = "SENDGRID_API_KEY"
            value = data.google_secret_manager_secret_version.sendgrid_api_key.secret_data
          }
          env {
            name = "SAML_ENTITY"
            value = "${var.subdomain}.dsp.garvan.org.au"
          }
        }
      }

    }
  }
}


resource "kubernetes_persistent_volume_claim" "ckan" {
  metadata {
    name = "ckan-claim-2"
    labels = {
        App = "ckan-${var.env}"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "local-path"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

data "google_secret_manager_secret_version" "idp_url" {
  secret = "idp_url"
}


data "google_secret_manager_secret_version" "sendgrid_api_key" {
  secret = "sendgrid-api-key"
}

resource "google_secret_manager_secret" "sess_key" {
  secret_id = "sess-key-${var.env}-k3s"

  replication {
    user_managed {
      replicas {
        location = "australia-southeast1"
      }
    }
  }

  provisioner "local-exec" { #This creates a randomly generated password
    command = "head /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c10 | gcloud secrets versions add sess-key-${var.env}-k3s --project=${var.project_id} --data-file=-"
  }
}

data "google_secret_manager_secret_version" "sess_key" {
  secret = google_secret_manager_secret.sess_key.secret_id
}

data "google_secret_manager_secret_version" "xloader_token" {
  secret = "xloader-token"
}

resource "google_secret_manager_secret" "secret_key" {
  secret_id = "secret-key-${var.env}-k3s"

  replication {
    user_managed {
      replicas {
        location = "australia-southeast1"
      }
    }
  }

  provisioner "local-exec" { #This creates a randomly generated password
    command = "head /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c10 | gcloud secrets versions add secret-key-${var.env}-k3s --project=${var.project_id} --data-file=-"
  }
}

data "google_secret_manager_secret_version" "secret_key" {
  secret = google_secret_manager_secret.secret_key.secret_id
}


resource "kubernetes_service" "ckan" {
  
  metadata {

    name = "ckan-${var.env}"
    labels = {
        App = "ckan-${var.env}"
    }
  }
  spec {
    selector = {
      App = "ckan-${var.env}" #This should match the kubernetes deployment
    }
    port {
      port = 80
      target_port = 8000
    }

    type = "NodePort"
  }
}



