resource "kubernetes_service_account" "device_service_account" {
  metadata {
    name      = "device-service"
    namespace = "services"
    labels = {
      app = "device-service"
    }
  }
}

resource "kubernetes_service" "device_service" {
  metadata {
    name      = "device-service"
    namespace = "services"
  }
  spec {
    selector = {
      app = "device-service"
    }
    port {
      port        = 7979
      target_port = 7979
    }
  }
}

resource "kubernetes_deployment" "device_deployment" {
  metadata {
    name      = "device-service"
    namespace = "services"
    labels = {
      app = "device-service"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "device-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "device-service"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject" = "true"
          "vault.hashicorp.com/role" = "device-service-role"
          "vault.hashicorp.com/agent-inject-secret-chain.crt" = "secret/mqtt-server-chain"
          "vault.hashicorp.com/agent-inject-template-chain.crt" = <<EOF
        {{- with secret "secret/mqtt-server-chain" -}}
        {{ .Data.data.chain_crt }}
        {{- end }}
EOF
        }
      }
      spec {
        service_account_name            = "device-service"
        automount_service_account_token = "true"
        container {
          image = "hengel2810/se09-device-service:76fa5c93a1cfdd5ac1c2b3d9df78285ea4aa853c"
          name  = "device-service"
          env {
            name  = "POSTGRES_HOST"
            value = "jdbc:postgresql://${data.digitalocean_database_cluster.postgres.host}:${data.digitalocean_database_cluster.postgres.port}/${postgresql_database.device_service.name}?sslmode=require"
          }
          env {
            name  = "POSTGRES_USER"
            value = digitalocean_database_user.device_service.name
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = digitalocean_database_user.device_service.password
          }
          env {
            name  = "VAULT_URL"
            value = "http://vault.vault.svc.cluster.local:8200"
          }
          env {
            name  = "USER_SERVICE_URL"
            value = "http://user-service.auth.svc.cluster.local:8585"
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service_account.device_service_account
  ]
}
