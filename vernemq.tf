data "helm_repository" "helm_repo_vernemq" {
  name = "vernemq"
  url  = "https://vernemq.github.io/docker-vernemq"
}

resource "null_resource" "vernemq_values" {
  provisioner "local-exec" {
    command = "export HOST=${digitalocean_database_connection_pool.cs_postgres_vernemq_pool.host} && export PORT=${digitalocean_database_connection_pool.cs_postgres_vernemq_pool.port} && export USER=${digitalocean_database_cluster.cs_postgres_cluster.user} && export PASSWORD=${digitalocean_database_cluster.cs_postgres_cluster.password} && export DATABASE=${digitalocean_database_connection_pool.cs_postgres_vernemq_pool.name} && ./scripts/vernemq-db.sh"
  }
  depends_on = [
    "local_file.kubeconfig",
    "helm_release.voyager_ingress_controller"
  ]
}

data "local_file" "vernemq_config" {
  filename = "configs/vernemq.yml"
  depends_on = [
    "null_resource.vernemq_values"
  ]
}

resource "helm_release" "vernemq_cluster" {
  name       = "vernemq-cluster"
  repository = "${data.helm_repository.helm_repo_vernemq.metadata.0.name}"
  chart      = "vernemq/vernemq"
  namespace  = "mqtt"
  set {
    name  = "replicaCount"
    value = 2
  }
  set {
    name  = "image.tag"
    value = "1.10.1"
  }
  values = [
    "${data.local_file.vernemq_config.content}"
  ]
  depends_on = [
    "kubernetes_cluster_role_binding.tiller",
    "kubernetes_service_account.tiller",
    "kubernetes_namespace.k8s_namespace_mqtt",
    "data.local_file.vernemq_config"
  ]
}

# resource "null_resource" "vernemq_values_clear" {
#   provisioner "local-exec" {
#     command = "rm configs/vernemq.yml && touch configs/vernemq.yml"
#   }
#   depends_on = [
#     "helm_release.vernemq_cluster"
#   ]
# }

resource "kubernetes_service" "mqtt_broker_service_http_debug" {
  metadata {
    name      = "vernemq-dashboard"
    namespace = "mqtt"
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "vernemq-cluster"
      "app.kubernetes.io/name"     = "vernemq"
    }
    port {
      port        = 8888
      target_port = 8888
    }
  }
}
