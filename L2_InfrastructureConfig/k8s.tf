data "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name = var.k8s_cluster_name
}

provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.k8s_cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_network_policy" "default_block_all" {
  metadata {
    name      = "default-block-network-policy"
    namespace = "default"
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}
