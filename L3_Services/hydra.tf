data "helm_repository" "ory" {
  name = "ory"
  url  = "https://k8s.ory.sh/helm/charts"
}

resource "helm_release" "hydra" {
  name = "hydra"
  repository = data.helm_repository.ory.metadata.0.name
  chart = "ory/hydra"
  namespace = "default"
  set {
    name = "hydra.config.secrets.system"
    value = "H874MrzXJQzesPNmSpVHnCCaYMZYjXtl"
  }
  set {
    name = "hydra.config.dsn"
    value = "postgres://${digitalocean_database_user.hydra.name}:${digitalocean_database_user.hydra.password}@${data.digitalocean_database_cluster.postgres.host}:${data.digitalocean_database_cluster.postgres.port}/${postgresql_database.user_service.name}?sslmode=require"
  }
  set {
    name = "hydra.config.urls.self.issuer"
    value = "https://api.engelbrink.dev/hydra"
  }
  set {
    name = "hydra.config.urls.login"
    value = "https://api.engelbrink.dev/user-service/auth/login"
  }
  set {
    name = "hydra.config.urls.consent"
    value = "https://api.engelbrink.dev/user-service/auth/consent"
  }
  set {
    name = "hydra.dangerousForceHttp"
    value = "true"
  }
  set {
    name = "hydra.autoMigrate"
    value = "true"
  }
  set {
    name = "hydra.config.ttl.access_token"
    value = "2h"
  }
  set {
    name = "hydra.config.ttl.refresh_token"
    value = "-1"
  }
}

resource "kubernetes_job" "hydra_init" {
  metadata {
    name      = "hydra-init"
    namespace = "default"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "hydra-init"
          image   = "hengel2810/se09-hydra-init:1.5"
          command = ["python", "./main.py"]
          env {
            name  = "HYDRA_HOST"
            value = "http://hydra-admin"
          }
          env {
            name  = "HYDRA_PORT"
            value = 4445
          }
          env {
            name  = "HYDRA_CLIENT_NAME"
            value = "ios-app"
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  depends_on = [
    helm_release.hydra
  ]
}
