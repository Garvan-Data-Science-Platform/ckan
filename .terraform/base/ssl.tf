module "cert_manager" {

  source        = "terraform-iaac/cert-manager/kubernetes"
  cluster_issuer_email                   = "t.kallady@garvan.org.au"
  cluster_issuer_server                  = "https://acme-v02.api.letsencrypt.org/directory"
  cluster_issuer_name                    = "cert-manager-global"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"

  cluster_issuer_yaml = file("../base/issuer.yaml")

  #additional_set = [
  #  {
  #      name = "extraArgs"
  #      value = "{--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=1.1.1.1:53}"
  #  }
  #]
}


resource "helm_release" "lego_webhook" {
    repository = "https://yxwuxuanl.github.io/cert-manager-lego-webhook/"
    chart = "cert-manager-lego-webhook"
    name = "lego-webhook"

    set {
        name = "groupName"
        value = "acme.garvan.webhook"
    }
    set {
        name = "certManager.namespace"
        value = "cert-manager"
    }
    set {
        name = "certManager.serviceAccount.name"
        value = "cert-manager"
    }


}