# resource "digitalocean_database_cluster" "cs_postgres_cluster" {
#   name = "cs-postgres-cluster"
#   engine = "pg"
#   version = "11"
#   size = "db-s-1vcpu-1gb"
#   region = "${var.region}"
#   node_count = 1
# }
# # 