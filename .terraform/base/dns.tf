


resource "kubernetes_service" "primary" {
  
  metadata {

    name = "primary"
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

resource "kubernetes_ingress_v1" "gke-ingress" {
  metadata {
    name = "gke-ingress"
    annotations = {
        #"cert-manager.io/cluster-issuer"=module.cert_manager.cluster_issuer_name
        "nginx.ingress.kubernetes.io/rewrite-target"="/"
    }
  }

  spec {
    ingress_class_name = "nginx"
    #tls {
    #  hosts = ["${var.subdomain}.garvan.org.au"]
    #  secret_name = "cert-manager-private-key"
    #}
    rule {
      host = "${var.subdomain}.garvan.org.au"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "primary"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "gke-ingress-2" {
  metadata {
    name = "gke-ingress-2"
    annotations = {
      #"cert-manager.io/cluster-issuer"=module.cert_manager.cluster_issuer_name
      "nginx.ingress.kubernetes.io/rewrite-target"="ckan-static/base/$1"
    }
  }

  spec {
    ingress_class_name = "nginx"
    #tls {
    #  hosts = ["${var.subdomain}.garvan.org.au"]
    #  secret_name = "test-tls"
    #}
    rule {
      host = "${var.subdomain}.garvan.org.au"
      http {
        path {
          path = "/base/(.+)"
          backend {
            service {
              name = "bucket-${var.env}"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "gke-ingress-3" {
  metadata {
    name = "gke-ingress-3"
    annotations = {
        "nginx.ingress.kubernetes.io/rewrite-target"="ckan-static/webassets/$1"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "${var.subdomain}.garvan.org.au"
      http {
        path {
          path = "/webassets/(.+)"
          backend {
            service {
              name = "bucket-${var.env}"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "bucket" {
  
  metadata {
    name = "bucket-${var.env}"
  }
  spec {
    type = "ExternalName"
    external_name = "storage.googleapis.com"

    port {
      port = 80
      target_port = 80
    }
  }
}