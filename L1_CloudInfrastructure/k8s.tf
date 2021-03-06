resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = var.k8s_cluster_name
  region  = var.region
  version = "1.16.6-do.2"

  node_pool {
    name       = "worker-pool"
    size       = "s-4vcpu-8gb"
    node_count = 3
  }
}

resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.raw_config
  filename = "kubeconfig.yaml"
  depends_on = [
    digitalocean_kubernetes_cluster.k8s_cluster
  ]
}
