resource "helm_release" "vault" {
  name      = "vault"
  chart     = "${path.module}/vault"
  namespace = "vault"
  values = [<<EOF
server:
  standalone:
    config: |
      storage "postgresql" {
        connection_url = "postgres://${digitalocean_database_user.vault.name}:${digitalocean_database_user.vault.password}@${data.digitalocean_database_cluster.postgres.host}:${data.digitalocean_database_cluster.postgres.port}/${postgresql_database.vault.name}"
      }
EOF
  ]
}
