resource "google_dns_record_set" "ckan" {

  name = "${var.subdomain}.dsp.garvan.org.au."
  type = "A"
  ttl  = 300

  managed_zone = "dsp"
  project = "ctrl-358804"

  rrdatas = ["34.151.105.103"]
}


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
        "cert-manager.io/issuer"="letsencrypt-prod"
        "nginx.ingress.kubernetes.io/rewrite-target"="/"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts = ["${var.subdomain}.dsp.garvan.org.au"]
      secret_name = "test-tls"
    }
    rule {
      host = "${var.subdomain}.dsp.garvan.org.au"
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
      "cert-manager.io/issuer"="letsencrypt-prod"
      "nginx.ingress.kubernetes.io/rewrite-target"="ckan-static/base/$1"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts = ["${var.subdomain}.dsp.garvan.org.au"]
      secret_name = "test-tls"
    }
    rule {
      host = "${var.subdomain}.dsp.garvan.org.au"
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
      host = "${var.subdomain}.dsp.garvan.org.au"
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