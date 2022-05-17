resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_name
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  data = var.extra_env
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "${var.app_name}-deployment"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = var.container
          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata.0.name
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.app_name}-service"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  wait_for_load_balancer = false
  spec {
    selector = {
      app = var.app_name
    }
    session_affinity = "ClientIP"
    port {
      port        = 8000
      target_port = var.application_port
    }
  }
}


resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  spec {
    ingress_class_name = "public"

    default_backend {
      service {
        name = kubernetes_service.app.metadata.0.name
        port {
          number = 8000
        }

      }
    }

    tls {
      hosts = [var.domain]
    }
  }
}
