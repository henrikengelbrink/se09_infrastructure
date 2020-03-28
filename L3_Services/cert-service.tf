resource "kubernetes_service_account" "cert_service_account" {
  metadata {
    name      = "cert-service"
    namespace = "default"
    labels = {
      app = "cert-service"
    }
  }
}

resource "kubernetes_service" "cert_service" {
  metadata {
    name      = "cert-service"
    namespace = "default"
  }
  spec {
    selector = {
      app = "cert-service"
    }
    port {
      port        = 7878
      target_port = 7878
    }
  }
}

resource "kubernetes_deployment" "cert_deployment" {
  metadata {
    name      = "cert-service"
    namespace = "default"
    labels = {
      app = "cert-service"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "cert-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "cert-service"
        }
      }
      spec {
        service_account_name            = "cert-service"
        automount_service_account_token = "true"
        container {
          image = "hengel2810/se09-cert-service:413193edc97d7b4dd8f5c7f9c5a7b22f3e06f02a"
          name  = "cert-service"
          env {
            name  = "POSTGRES_HOST"
            value = "jdbc:postgresql://${data.digitalocean_database_cluster.postgres.host}:${data.digitalocean_database_cluster.postgres.port}/${postgresql_database.cert_service.name}?sslmode=require"
          }
          env {
            name  = "POSTGRES_USER"
            value = digitalocean_database_user.cert_service.name
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = digitalocean_database_user.cert_service.password
          }
          env {
            name  = "VAULT_URL"
            value = "http://vault:8200"
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service_account.cert_service_account
  ]
}
