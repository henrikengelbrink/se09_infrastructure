data "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name = var.k8s_cluster_name
}

provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.k8s_cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.cluster_ca_certificate)
}

//resource "kubernetes_namespace" "k8s_namespace_voyager" {
//  metadata {
//    name = "voyager"
//  }
//}
//
//resource "kubernetes_namespace" "k8s_namespace_mqtt" {
//  metadata {
//    name = "mqtt"
//  }
//}
//
//resource "kubernetes_namespace" "k8s_namespace_services" {
//  metadata {
//    name = "services"
//  }
//}
//
//resource "kubernetes_namespace" "k8s_namespace_vault" {
//  metadata {
//    name = "vault"
//  }
//}
//
//resource "kubernetes_namespace" "k8s_namespace_auth" {
//  metadata {
//    name = "auth"
//  }
//}