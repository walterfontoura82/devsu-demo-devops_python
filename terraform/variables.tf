variable "namespace" {
  description = "Kubernetes namespace where the application will run."
  type        = string
  default     = "devsu-demo"
}

variable "app_name" {
  description = "Base name used for Kubernetes resources."
  type        = string
  default     = "django-app"
}

variable "image_repository" {
  description = "Container image repository."
  type        = string
  default     = "ghcr.io/walterfontoura82/devsu-demo-devops_python"
}

variable "image_tag" {
  description = "Container image tag to deploy."
  type        = string
  default     = "latest"
}

variable "replicas" {
  description = "Initial number of pod replicas."
  type        = number
  default     = 2
}

variable "min_replicas" {
  description = "Minimum number of replicas managed by the HPA."
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum number of replicas managed by the HPA."
  type        = number
  default     = 5
}

variable "cpu_average_utilization" {
  description = "CPU utilization target percentage for the HPA."
  type        = number
  default     = 70
}

variable "ingress_host" {
  description = "Hostname used by the Kubernetes Ingress."
  type        = string
  default     = "devsu-demo.local"
}

variable "django_secret_key" {
  description = "Django secret key injected into the application."
  type        = string
  sensitive   = true
}

variable "django_debug" {
  description = "Django debug flag."
  type        = string
  default     = "False"
}

variable "django_allowed_hosts" {
  description = "Comma-separated list of allowed hosts for Django."
  type        = string
  default     = "devsu-demo.local,localhost,127.0.0.1"
}

variable "database_name" {
  description = "SQLite database file name."
  type        = string
  default     = "db.sqlite3"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used by the Kubernetes provider."
  type        = string
  default     = null
}

variable "kubeconfig_context" {
  description = "Optional kubeconfig context."
  type        = string
  default     = null
}
