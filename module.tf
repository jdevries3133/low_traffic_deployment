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

  data = {
    POSTGRESQL_DB       = var.app_name
    POSTGRESQL_HOST     = "${helm_release.db.name}-postgresql.${kubernetes_namespace.app.metadata.0.name}.svc.cluster.local"
    POSTGRESQL_USERNAME = var.app_name
    POSTGRESQL_PASSWORD = random_password.db_password.result
  }
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "${var.app_name}-secrets"
    namespace = kubernetes_namespace.app.metadata.0.name
  }
  data = {
    POSTGRESQL_PASSWORD = random_password.db_password.result
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "${var.app_name}-deployment"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  spec {
    replicas = 2

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

          env_from {
            secret_ref {
              name = kubernetes_secret.app_secrets.metadata.0.name
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
      port = var.application_port
    }
  }
}


resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    ingress_class_name = "public"

    tls {
      hosts = [var.domain]
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
                number = var.application_port
              }
            }
          }
        }
      }
    }
  }
}


/******************************************************************************
 * Postgresql DB
 */

resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "helm_release" "db" {
  name       = "db"
  namespace  = kubernetes_namespace.app.metadata.0.name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "10.16.1"

  set {
    name  = "global.postgresql.postgresqlDatabase"
    value = var.app_name
  }

  set {
    name  = "global.postgresql.postgresqlUsername"
    value = var.app_name
  }


  set {
    name  = "global.storageClass"
    value = "openebs-jiva-csi-default"
  }

  set_sensitive {
    name  = "global.postgresql.postgresqlPassword"
    value = random_password.db_password.result
  }

}
