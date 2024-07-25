resource "helm_release" "redis" {

  name = "redis-${var.env}"

  #repository       = "https://helm.elastic.co"
  chart            = "oci://registry-1.docker.io/bitnamicharts/redis"
  #version          = "7.16.3"

  depends_on = [google_container_node_pool.primary_nodes]

  #set {
  #  name = "auth.password"
  #  value = data.google_secret_manager_secret_version.redis_password.secret_data
  #}

  set {
    name = "master.service.type"
    value = "ClusterIP"
  }
  
  set {
    name = "replica.replicaCount"
    value = 0
  }

  set {
    name = "auth.enabled"
    value = false
  }
  
}


