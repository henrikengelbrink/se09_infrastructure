data "helm_repository" "helm_repo_vernemq" {
    name = "vernemq"
    url  = "https://vernemq.github.io/docker-vernemq"
}

resource "helm_release" "vernemq_cluster" {
    name = "vernemq-cluster"
    repository = "${data.helm_repository.helm_repo_vernemq.metadata.0.name}"
    chart = "vernemq/vernemq"
    namespace = "mqtt"
    set {
      name  = "replicaCount"
      value = 2
    }
    set {
      name  = "image.tag"
      value = "1.10.1"
    }
    values = [
      "${file("./configs/vernemq.yml")}"
    ]
    depends_on = [
      "kubernetes_cluster_role_binding.tiller",
      "kubernetes_service_account.tiller",
      "kubernetes_namespace.k8s_namespace_mqtt"
    ]
}

resource "kubernetes_service" "mqtt_broker_service_http_debug" {
  metadata {
    name      = "vernemq-dashboard"
    namespace = "mqtt"
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "vernemq-cluster"
      "app.kubernetes.io/name" = "vernemq"
    }
    port {
      port = 8888
      target_port = 8888
    }
  }
}
