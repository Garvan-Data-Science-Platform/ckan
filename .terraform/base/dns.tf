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
        "ingress.gcp.kubernetes.io/pre-shared-cert"=google_compute_managed_ssl_certificate.lb_default.name
    }
  }

  spec {
    ingress_class_name = "nginx"
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