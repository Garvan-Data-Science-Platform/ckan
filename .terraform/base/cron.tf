resource "kubernetes_cron_job_v1" "mailer" {
  metadata {
    name = "mailer-${var.env}"
  }

  spec {

    schedule = "0 0 * * *" #10am utc
    
    job_template {

      metadata {}
      spec {

        template {
          metadata {}

          spec {

            image_pull_secrets {
              name="regcred"
            }

            container {
              image = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/ckan"
              image_pull_policy = "Always"
              name  = "ckan-mailer"

              command = ["/bin/bash", "-c", "./docker/parse-config.sh docker/ckan.ini.template > /app/ckan.ini && ckan -c ckan.ini notify send_emails && ckan -c ckan.ini tracking update && ckan -c ckan.ini search-index rebuild -r"]

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
                value = "ckan.dsp.garvan.org.au"
              }
            }
          }

        }


      }

    }
  }
}

