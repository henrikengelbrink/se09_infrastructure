data "digitalocean_database_cluster" "postgres" {
  name = var.postgres_cluster_name
}

resource "digitalocean_database_user" "device_service" {
  cluster_id = data.digitalocean_database_cluster.postgres.id
  name       = "device-service"
}

resource "digitalocean_database_user" "user_service" {
  cluster_id = data.digitalocean_database_cluster.postgres.id
  name       = "user-service"
}

resource "digitalocean_database_user" "cert_service" {
  cluster_id = data.digitalocean_database_cluster.postgres.id
  name       = "cert-service"
}

resource "digitalocean_database_user" "hydra" {
  cluster_id = data.digitalocean_database_cluster.postgres.id
  name       = "hydra"
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

resource "postgresql_database" "device_service" {
  name              = "device-service"
  owner             = digitalocean_database_user.device_service.name
  allow_connections = true
}

resource "postgresql_database" "user_service" {
  name              = "user-service"
  owner             = digitalocean_database_user.user_service.name
  allow_connections = true
}

resource "postgresql_database" "cert_service" {
  name              = "cert-service"
  owner             = digitalocean_database_user.cert_service.name
  allow_connections = true
}

resource "postgresql_database" "hydra" {
  name              = "hydra"
  owner             = digitalocean_database_user.hydra.name
  allow_connections = true
}
