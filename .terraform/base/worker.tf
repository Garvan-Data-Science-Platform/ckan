resource "kubernetes_deployment" "worker" {
  metadata {
    name = "worker-${var.env}"
  }

  depends_on = [helm_release.postgres]

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "worker-${var.env}"
      }
    }
    template {
      metadata {
        labels = {
          App = "worker-${var.env}"
        }
      }
      
      spec {

        image_pull_secrets {
          name="regcred"
        }

        container {
          image = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/ckan:latest"
          name  = "worker"

          command = ["./docker/entrypoint-worker.sh"]

          env {
            name = "SITE_URL"
            value = "https://${var.subdomain}.garvan.org.au"
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
            name = "SOLR_HOST"
            value = "solr-${var.env}"
          }
          env {
            name = "REDIS_HOST"
            value = "redis-${var.env}-master"
          }
          env {
            name = "IDP_URL"
            value = data.google_secret_manager_secret_version.idp_url.secret_data
          }
          env {
            name = "SAML_ENTITY"
            value = "${var.subdomain}.garvan.org.au"
          }
        }
      }

    }
  }
}
