resource "google_kms_key_ring" "key_ring" {
  project  = var.gcloud_project
  name     = "kms-vault-key-17"
  location = var.gcloud_region
}

resource "google_kms_crypto_key" "crypto_key" {
  name            = "kms-vault-crypto-key-17"
  key_ring        = google_kms_key_ring.key_ring.self_link
  rotation_period = "100000s"
}

resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.key_ring.id
  role        = "roles/owner"
  members = [
    "serviceAccount:vault-911@k8s-based-iot.iam.gserviceaccount.com"
  ]
}

resource "kubernetes_secret" "gcp_credentials" {
  metadata {
    name      = "kms-creds"
    namespace = "default"
  }
  data = {
    "credentials.json" = file("${path.cwd}/${var.gcp_account_file_path}")
  }
}

resource "kubernetes_job" "vault_db_init" {
  metadata {
    name      = "vault-db-init"
    namespace = "default"
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
  namespace = "default"
  depends_on = [
    kubernetes_secret.gcp_credentials,
    kubernetes_job.vault_db_init
  ]
  values = [<<EOF
injector:
  enabled: true
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

resource "kubernetes_service_account" "vault_injector_account" {
  metadata {
    name      = "vault-auth"
    namespace = "default"
    labels = {
      app = "vault-app"
    }
  }
  depends_on = [
    helm_release.vault
  ]
}

data "external" "vault_token_name" {
  program = ["bash", "${path.module}/scripts/vault.sh"]
  depends_on = [
    helm_release.vault
  ]
}

resource "kubernetes_pod" "vault_init" {
  metadata {
    name      = "vault-init"
    namespace = "default"
  }
  spec {
    restart_policy                  = "Never"
    automount_service_account_token = true
    service_account_name            = "vault"
    container {
      name    = "vault-init"
      image   = "hengel2810/se09-vault-init:0.67"
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
      env {
        name  = "K8S_HOST"
        value = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.host
      }
      env {
        name  = "K8S_CA_CERT"
        value = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.cluster_ca_certificate
      }
      env {
        name  = "K8S_TOKEN"
        value = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.token
      }
      env {
        name  = "CLUSTER_TOKEN"
        value = data.external.vault_token_name.result.token
      }
    }
  }
  depends_on = [
    helm_release.vault
  ]
}

resource "null_resource" "vault" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=default apply -f ./crds/vault.yml"
  }
}
