data "helm_repository" "datawire_helm_repo" {
  name = "datawire"
  url  = "https://www.getambassador.io"
}

resource "helm_release" "ambassador_ingress_controller" {
  repository = "${data.helm_repository.datawire_helm_repo.metadata.0.name}"
  name       = "ambassador"
  chart      = "datawire/ambassador"
  version    = "v1.1.0"
  namespace  = "ambassador"
  depends_on = [
    "kubernetes_cluster_role_binding.tiller",
    "kubernetes_service_account.tiller",
  ]
}