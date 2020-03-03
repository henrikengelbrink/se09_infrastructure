resource "google_kms_key_ring" "key_ring" {
  project  = var.gcloud_project
  name     = "kms-vault-key-5"
  location = var.gcloud_region
}

resource "google_kms_crypto_key" "crypto_key" {
  name            = "kms-vault-crypto-key-5"
  key_ring        = google_kms_key_ring.key_ring.self_link
  rotation_period = "100000s"
}

resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.key_ring.id
  role = "roles/owner"
  members = [
    "serviceAccount:vault-911@k8s-based-iot.iam.gserviceaccount.com"
  ]
}

resource "kubernetes_secret" "gcp_credentials" {
  metadata {
    name      = "kms-creds"
    namespace = "vault"
  }
  data = {
    "credentials.json" = file("${path.cwd}/${var.gcp_account_file_path}")
  }
}

resource "kubernetes_job" "vault_db_init" {
  metadata {
    name = "vault-db-init"
    namespace = "vault"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "vault-db-init"
          image   = "hengel2810/se09-vault-db-init:0.3"
          command = ["python", "./main.py"]
          env {
            name  = "POSTGRES_HOST"
            value = data.digitalocean_database_cluster.postgres.host
          }
          env {
            name  = "POSTGRES_PORT"
            value = data.digitalocean_database_cluster.postgres.port
          }
          env {
            name  = "POSTGRES_USER"
            value = digitalocean_database_user.vault.name
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = digitalocean_database_user.vault.password
          }
          env {
            name  = "POSTGRES_DB_NAME"
            value = postgresql_database.vault.name
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  depends_on = [
    postgresql_database.vault
  ]
}

resource "helm_release" "vault" {
  name      = "vault"
  chart     = "${path.module}/vault"
  namespace = "vault"
  depends_on = [
    kubernetes_secret.gcp_credentials,
    kubernetes_job.vault_db_init
  ]
  values = [<<EOF
server:
  extraVolumes:
    - type: secret
      name: kms-creds
  extraEnvironmentVars:
    GOOGLE_REGION: ${var.gcloud_region}
    GOOGLE_PROJECT:  ${var.gcloud_project}
    GOOGLE_APPLICATION_CREDENTIALS: /vault/userconfig/kms-creds/credentials.json
  standalone:
    config: |
      ui = true
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "postgresql" {
        connection_url = "postgres://${digitalocean_database_user.vault.name}:${digitalocean_database_user.vault.password}@${data.digitalocean_database_cluster.postgres.host}:${data.digitalocean_database_cluster.postgres.port}/${postgresql_database.vault.name}"
      }
      seal "gcpckms" {
        project     = "${var.gcloud_project}"
        region      = "${var.gcloud_region}"
        key_ring    = "${google_kms_key_ring.key_ring.name}"
        crypto_key  = "${google_kms_crypto_key.crypto_key.name}"
      }
EOF
  ]
}

resource "kubernetes_job" "vault_init" {
  metadata {
    name = "vault-init"
    namespace = "vault"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "vault-init"
          image   = "hengel2810/se09-vault-init:0.27"
          command = ["python", "./main.py"]
          env {
            name  = "VAULT_HOST"
            value = "vault"
          }
          env {
            name  = "VAULT_PORT"
            value = 8200
          }
          env {
            name  = "CERT_ROOT_DOMAIN"
            value = "engelbrink.dev"
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  depends_on = [
    helm_release.vault
  ]
}
