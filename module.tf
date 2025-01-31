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
    annotations = {
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
      "acme.cert-manager.io/http01-edit-in-place"   = "true"
      "cert-manager.io/issue-temporary-certificate" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.domain]
      secret_name = "${var.app_name}-tls-certificate"
    }

    rule {
      host = var.domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app.metadata.0.name
              port {
                number = 8000
              }
            }
          }
        }
      }
    }
  }
}
