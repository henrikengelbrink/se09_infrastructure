data "helm_repository" "appscode" {
  name = "appscode"
  url  = "https://charts.appscode.com/stable/"
}

resource "helm_release" "voyager" {
  repository = data.helm_repository.appscode.metadata.0.name
  name       = "ingress-controller"
  chart      = "appscode/voyager"
  version    = "v12.0.0-rc.1"
  namespace  = kubernetes_namespace.k8s_namespace_voyager.metadata.0.name
  set {
    name  = "ingressClass"
    value = "voyager-ingress"
  }
  set {
    name  = "cloudProvider"
    value = "digitalocean"
  }
}

resource "kubernetes_secret" "acme_secret_k8s" {
  metadata {
    name      = "acme-account"
    namespace = kubernetes_namespace.k8s_namespace_voyager.metadata.0.name
  }
  data = {
    ACME_EMAIL = "hengel2810@gmail.com"
    #ACME_SERVER_URL = "https://acme-staging-v02.api.letsencrypt.org/directory"
    ACME_SERVER_URL = "https://acme-v02.api.letsencrypt.org/directory"
  }
}

resource "kubernetes_secret" "dns_digital_ocean_secret_k8s" {
  metadata {
    name      = "do-dns-secret"
    namespace = kubernetes_namespace.k8s_namespace_voyager.metadata.0.name
  }
  data = {
    DO_AUTH_TOKEN = var.do_token
  }
  depends_on = [
    kubernetes_secret.acme_secret_k8s
  ]
}

resource "null_resource" "ingress" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=voyager apply -f ./crds/voyager-ingress.yml"
  }
  depends_on = [
    kubernetes_secret.acme_secret_k8s,
    helm_release.voyager
  ]
}

resource "null_resource" "load_balancer_delay" {
  provisioner "local-exec" {
    command = "./scripts/load-balancer.sh"
  }
  triggers = {
    "before" = null_resource.ingress.id
  }
  depends_on = [
    null_resource.ingress,
    helm_release.voyager
  ]
}

resource "null_resource" "voyager_cert" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=voyager apply -f ./crds/voyager-cert.yml"
  }
  depends_on = [
    digitalocean_domain.dns_cluster_domain,
    helm_release.voyager
  ]
}
