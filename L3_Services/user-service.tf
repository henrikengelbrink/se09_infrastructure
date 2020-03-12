resource "kubernetes_service" "user_service" {
  metadata {
    name      = "user-service"
    namespace = "auth"
  }
  spec {
    selector = {
      app = "user-service"
    }
    port {
      port        = 8585
      target_port = 8585
    }
  }
}

resource "kubernetes_deployment" "user_deployment" {
  metadata {
    name      = "user-service"
    namespace = "auth"
    labels = {
      app = "user-service"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "user-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "user-service"
        }
      }
      spec {
        container {
          image = "hengel2810/se09-user-service:a05410d338d8a90e39b359ac198b80cc86229f13"
          name  = "user-service"
          env {
            name  = "PORT"
            value = 8585
          }
          env {
            name  = "POSTGRES_HOST"
            value = "jdbc:postgresql://${data.digitalocean_database_cluster.postgres.host}:${data.digitalocean_database_cluster.postgres.port}/${postgresql_database.user_service.name}?sslmode=require"
          }
          env {
            name  = "POSTGRES_USER"
            value = digitalocean_database_user.user_service.name
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = digitalocean_database_user.user_service.password
          }
          env {
            name  = "HYDRA_URL_PUBLIC"
            value = "http://hydra-admin:4445"
          }
          env {
            name = "EXTERNAL_HOSTNAME"
            value = "https://user.engelbrink.dev"
          }
//          liveness_probe {
//            http_get {
//              path = "/health"
//              port = 8585
//            }
//            initial_delay_seconds = 30
//            period_seconds        = 10
//          }
        }
      }
    }
  }
}