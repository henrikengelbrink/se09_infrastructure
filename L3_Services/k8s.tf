data "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name = var.k8s_cluster_name
}

provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.k8s_cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.cluster_ca_certificate)
}

resource "null_resource" "pod_security_policy" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=default apply -f ./crds/psd.yml"
  }
}
