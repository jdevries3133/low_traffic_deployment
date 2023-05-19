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

  data = merge({
    POSTGRES_DB   = var.app_name
    POSTGRES_HOST = "${kubernetes_deployment.db.metadata.0.name}.${kubernetes_namespace.app.metadata.0.name}.svc.cluster.local"
    POSTGRES_USER = var.app_name
  }, var.extra_env)
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "${var.app_name}-secrets"
    namespace = kubernetes_namespace.app.metadata.0.name
  }
  data = {
    POSTGRES_PASSWORD = random_password.db_password.result
    DATABASE_URL = join("", [
      "postgresql://",
      var.app_name,
      ":", random_password.db_password.result,
      "@",
      "${kubernetes_deployment.db.metadata.0.name}.${kubernetes_namespace.app.metadata.0.name}.svc.cluster.local:5432",
      "/", var.app_name
    ])
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
          startup_probe {
            http_get {
              path = var.startup_probe_path
              port = var.application_port
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
                number = 8000
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
  length  = 48
  special = false
}

resource "kubernetes_persistent_volume_claim" "db_data" {
  metadata {
    name      = "${var.app_name}-db-pvc"
    namespace = kubernetes_namespace.app.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
    storage_class_name = "ssd"
  }
}

resource "kubernetes_deployment" "db" {
  metadata {
    name      = "${var.app_name}-psql"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${var.app_name}-psql"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.app_name}-psql"
        }
      }
      spec {
        container {
          name  = "${var.app_name}-psql"
          image = "postgresql/postgresql:15.2-bullseye"
          // database name
          env {
            name  = "POSTGRES_DB"
            value = var.app_name
          }
          env {
            name  = "POSTGRES_USER"
            value = var.app_name
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = random_password.db_password.result
          }
          volume_mount {
            name = kubernetes_persistent_volume_claim.db_data.metadata.0.name
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }
  }
}
