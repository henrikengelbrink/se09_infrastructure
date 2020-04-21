data "digitalocean_database_cluster" "postgres" {
  name = var.postgres_cluster_name
}

resource "digitalocean_database_user" "vault" {
  cluster_id = data.digitalocean_database_cluster.postgres.id
  name       = "vault"
}

provider "postgresql" {
  host             = data.digitalocean_database_cluster.postgres.host
  port             = data.digitalocean_database_cluster.postgres.port
  database         = data.digitalocean_database_cluster.postgres.database
  username         = data.digitalocean_database_cluster.postgres.user
  password         = data.digitalocean_database_cluster.postgres.password
  expected_version = data.digitalocean_database_cluster.postgres.version
  superuser        = false
}

resource "postgresql_database" "vault" {
  name              = "vault"
  owner             = digitalocean_database_user.vault.name
  allow_connections = true
}

resource "digitalocean_database_firewall" "postgres_firewall" {
  cluster_id = data.digitalocean_database_cluster.postgres.id

  rule {
    type  = "ip_addr"
    # Enter OpenVPN IP address
    value = "0.0.0.0"
  }

  rule {
    type  = "k8s"
    value = data.digitalocean_kubernetes_cluster.k8s_cluster.id
  }
}