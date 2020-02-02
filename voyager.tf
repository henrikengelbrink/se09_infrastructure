data "helm_repository" "appscode_helm_repo" {
  name = "appscode"
  url  = "https://charts.appscode.com/stable/"
}

resource "helm_release" "voyager_ingress_controller" {
  repository = "${data.helm_repository.appscode_helm_repo.metadata.0.name}"
  name       = "ingress-controller"
  chart      = "appscode/voyager"
  version    = "v12.0.0-rc.1"
  namespace  = "voyager"
  set {
    name  = "ingressClass"
    value = "voyager-ingress"
  }
  set {
    name  = "cloudProvider"
    value = "digitalocean"
  }
  depends_on = [
    "kubernetes_cluster_role_binding.tiller",
    "kubernetes_service_account.tiller",
  ]
}

resource "null_resource" "acme_secret" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./kubeconfig.yaml --namespace=voyager create secret generic acme-account --from-literal=ACME_EMAIL=hengel2810@gmail.com"
  }
  depends_on = [
    "local_file.kubeconfig",
    "helm_release.voyager_ingress_controller"
  ]
}

resource "null_resource" "dns_digital_ocean_secret" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./kubeconfig.yaml --namespace=voyager create secret generic do-dns-secret --from-literal=DO_AUTH_TOKEN=${var.do_token}"
  }
  depends_on = [
    "null_resource.acme_secret"
  ]
}

resource "null_resource" "ingress" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./kubeconfig.yaml --namespace=voyager apply -f ./k8s_crd/voyager-ingress.yml"
  }
  depends_on = [
    "null_resource.acme_secret"
  ]
}

resource "null_resource" "load_balancer_delay" {
  provisioner "local-exec" {
    command = "./scripts/load-balancer.sh"
  }
  triggers = {
    "before" = "${null_resource.ingress.id}"
  }
}

resource "null_resource" "voyager_cert" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./kubeconfig.yaml --namespace=voyager apply -f ./k8s_crd/voyager-cert.yml"
  }
  depends_on = [
    "local_file.kubeconfig",
    "data.digitalocean_domain.dns_cluster_domain",
    "helm_release.voyager_ingress_controller"
  ]
}
