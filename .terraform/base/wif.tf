
# Service account associated with workload identity pool


resource "google_project_service" "wif_api" {
  for_each = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

module "gh_oidc" {
  source            = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version           = "v3.1.2"
  project_id        = var.project_id
  pool_id           = "ckan-gh-identity-pool"
  pool_display_name = "GitHub Identity Pool"
  provider_id       = "ckan-gh-provider"
  sa_mapping = {
    "github-access" = {
      sa_name   = "projects/garvan-data-hub/serviceAccounts/${var.sa_email}"
      attribute = "attribute.repository/Garvan-Data-Science-Platform/ckan"
    }
  }
}