resource "kubernetes_service" "user_service" {
  metadata {
    name      = "user-service"
    namespace = "default"
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
    namespace = "default"
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
          image = "hengel2810/se09-user-service:e0e510e222a977c7308c55c88244d766b7db0ad2"
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
            name  = "HYDRA_URL_ADMIN"
            value = "http://hydra-admin:4445"
          }
          env {
            name = "EXTERNAL_HOSTNAME"
            value = "https://api.engelbrink.dev/user-service"
          }
          env {
            name = "CERT_SERVICE_URL"
            value = "http://cert-service:7878"
          }
          env {
            name = "HIBP_SERVICE_URL"
            value = "http://hibp-service:8080"
          }
        }
      }
    }
  }
}
