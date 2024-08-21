resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google-beta
  name     = "ckan-${var.env}-ssl-cert-k3s"

  managed {
    domains = ["${var.subdomain}.dsp.garvan.org.au"]
  }
}
