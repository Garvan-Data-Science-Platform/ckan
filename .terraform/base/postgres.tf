resource "helm_release" "postgres" {

  name = "postgres-${var.env}"

  #repository       = "https://helm.elastic.co"
  chart            = "oci://registry-1.docker.io/bitnamicharts/postgresql"

  #set {
  #  name = "primary.nodeSelector"
  #  value = yamlencode({"kubernetes.io/hostname": "k3s"})
  #}
  set {
    name = "auth.password"
    value = data.google_secret_manager_secret_version.postgres_password.secret_data
  }
  set {
    name = "image.tag"
    value = "16"
  }
  values = ["${replace(file("../base/db-init.yaml"),"##DBPASSWORD##",data.google_secret_manager_secret_version.postgres_password.secret_data)}"]
  set {
    name = "auth.username"
    value = "ckan_default"
  }
  set {
    name = "auth.postgresPassword"
    value = data.google_secret_manager_secret_version.postgres_password.secret_data 
  }
  set {
    name = "primary.initdb.user"
    value = "postgres"
  }
  set {
    name = "primary.initdb.password"
    value = data.google_secret_manager_secret_version.postgres_password.secret_data 
  }

  set {
    name = "auth.database"
    value = "ckan_default"
  }

  set {
    name = "master.service.type"
    value = "ClusterIP"
  }
  
}

resource "google_secret_manager_secret" "postgres_password" {
  secret_id = "postgres-password-${var.env}-k3s"

  replication {
    user_managed {
      replicas {
        location = "australia-southeast1"
      }
    }
  }

  provisioner "local-exec" { #This creates a randomly generated password
    command = "head /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c10 | gcloud secrets versions add postgres-password-${var.env}-k3s --project=${var.project_id} --data-file=-"
  }
}

data "google_secret_manager_secret_version" "postgres_password" {
  secret = google_secret_manager_secret.postgres_password.secret_id
}