output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "location" {
    value = var.location
    description = "GCloud Location"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "sa_email" {
  value = var.sa_email
}

output "subdomain" {
  value = var.subdomain
}

//output "load_balancer_ip" {
//  value = kubernetes_ingress_v1.gke-ingress.status.0.load_balancer.0.ingress.0.ip
//}