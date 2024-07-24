resource "google_dns_record_set" "ckan" {

  name = "${var.subdomain}.dsp.garvan.org.au."
  type = "A"
  ttl  = 300

  managed_zone = "dsp"
  project = "ctrl-358804"

  rrdatas = [coalesce(data.google_compute_global_address.ckan-static.address,"1.1.1.1")]
}

resource "google_compute_global_address" "ckan-static" {
  name = "ipv4-address-api-${var.env}"
}

data "google_compute_global_address" "ckan-static" {
  depends_on = [google_compute_global_address.ckan-static]
  name = "ipv4-address-api-${var.env}"
}

resource "kubernetes_service" "primary" {
  
  metadata {
    annotations = {
      "cloud.google.com/neg": "{\"ingress\": true}",
    }
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
  wait_for_load_balancer = true
  metadata {
    name = "gke-ingress"
    annotations = {
        "kubernetes.io/ingress.global-static-ip-name"=google_compute_global_address.ckan-static.name
        "kubernetes.io/ingress.class"="gce"
        "ingress.gcp.kubernetes.io/pre-shared-cert"=google_compute_managed_ssl_certificate.lb_default.name
    }
  }

  spec {
    default_backend {
      service {
        name = "primary"
        port {
          number = 80
        }
      }
    }
  }
}