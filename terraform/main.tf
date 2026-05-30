locals {
  labels = {
    app = var.app_name
  }

  container_image = "${var.image_repository}:${var.image_tag}"
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "django" {
  metadata {
    name      = "django-secret"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  type = "Opaque"

  data = {
    DJANGO_SECRET_KEY    = var.django_secret_key
    DJANGO_DEBUG         = var.django_debug
    DJANGO_ALLOWED_HOSTS = var.django_allowed_hosts
    DATABASE_NAME        = var.database_name
  }
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name              = var.app_name
          image             = local.container_image
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8000
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.django.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/api/"
              port = 8000

              http_header {
                name  = "Host"
                value = "localhost"
              }
            }

            initial_delay_seconds = 10
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/api/"
              port = 8000

              http_header {
                name  = "Host"
                value = "localhost"
              }
            }

            initial_delay_seconds = 15
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = "django-service"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    selector = local.labels

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "django-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.app.metadata[0].name

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

resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name      = "${var.app_name}-hpa"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.app.metadata[0].name
    }

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = var.cpu_average_utilization
        }
      }
    }
  }
}
