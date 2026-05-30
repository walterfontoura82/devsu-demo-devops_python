output "namespace" {
  description = "Namespace used by the deployment."
  value       = kubernetes_namespace_v1.app.metadata[0].name
}

output "application_image" {
  description = "Container image deployed by Terraform."
  value       = local.container_image
}

output "ingress_host" {
  description = "Application ingress host."
  value       = var.ingress_host
}
