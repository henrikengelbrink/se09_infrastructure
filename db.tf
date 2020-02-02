resource "digitalocean_database_cluster" "cs_postgres_cluster" {
  name       = "cs-postgres-cluster-test"
  engine     = "pg"
  version    = "11"
  size       = "db-s-1vcpu-1gb"
  region     = "${var.region}"
  node_count = 1
}

resource "digitalocean_database_connection_pool" "cs_postgres_vernemq_pool" {
  cluster_id = "${digitalocean_database_cluster.cs_postgres_cluster.id}"
  name       = "vernemq-pool"
  mode       = "transaction"
  size       = 10
  db_name    = "${digitalocean_database_db.database_vernemq.name}"
  user       = "doadmin"
  depends_on = [
    "digitalocean_database_db.database_vernemq"
  ]
}

resource "digitalocean_database_db" "database_vernemq" {
  cluster_id = "${digitalocean_database_cluster.cs_postgres_cluster.id}"
  name       = "vernemq"
}

resource "digitalocean_database_db" "database_vault" {
  cluster_id = "${digitalocean_database_cluster.cs_postgres_cluster.id}"
  name       = "vault"
}
