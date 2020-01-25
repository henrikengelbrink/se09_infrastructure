resource "digitalocean_kubernetes_cluster" "iot_cluster" {
  name = "${var.cluster_name}"
  region = "${var.region}"
  version = "1.15.5-do.3"

  node_pool {
    name = "worker-pool"
    size = "s-2vcpu-4gb"
    node_count = 3
  }
}

resource "local_file" "kubeconfig" {
    content = "${digitalocean_kubernetes_cluster.iot_cluster.kube_config.0.raw_config}"
    filename = "kubeconfig.yaml"
}

provider "kubernetes" {
    host  = "${digitalocean_kubernetes_cluster.iot_cluster.endpoint}"
    token = "${digitalocean_kubernetes_cluster.iot_cluster.kube_config.0.token}"
    cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.iot_cluster.kube_config.0.cluster_ca_certificate)}"
}

resource "kubernetes_namespace" "k8s_namespace_voyager" {
  metadata {
    name = "voyager"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "k8s_namespace_mqtt" {
  metadata {
    name = "mqtt"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "k8s_namespace_http" {
  metadata {
    name = "http"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "k8s_namespace_elastic" {
  metadata {
    name = "elastic"
    labels = {
      istio-injection = "enabled"
    }
  }
}
