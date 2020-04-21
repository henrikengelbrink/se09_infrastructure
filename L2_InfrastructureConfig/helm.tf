provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.k8s_cluster.endpoint
    token                  = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.token
    client_certificate     = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.cluster_ca_certificate)
  }
}
