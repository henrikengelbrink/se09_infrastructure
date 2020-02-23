provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.k8s_cluster.endpoint
    token                  = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.token
    client_certificate     = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.cluster_ca_certificate)
  }
}

//resource "kubernetes_service_account" "tiller" {
//  metadata {
//    name      = "tiller"
//    namespace = "kube-system"
//  }
//}
//
//resource "kubernetes_cluster_role_binding" "tiller" {
//  metadata {
//    name = "tiller"
//  }
//  role_ref {
//    api_group = "rbac.authorization.k8s.io"
//    kind      = "ClusterRole"
//    name      = "cluster-admin"
//  }
//  subject {
//    kind      = "ServiceAccount"
//    name      = "tiller"
//    namespace = "kube-system"
//  }
//}
//
//provider "helm" {
//  install_tiller  = true
//  # tiller_image    = "v2.16.1"
//  service_account = kubernetes_service_account.tiller.metadata.0.name
//  kubernetes {
//    config_path = "./kubeconfig.yaml"
//  }
//}
