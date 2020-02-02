# resource "helm_release" "helm_vault" {
#   name       = "vault"
#   repository = "https://github.com/hashicorp/vault-helm.git"
#   chart      = "vault-helm"
#   version    = "v0.3.3"

# #   values = [
# #     "${file("values.yaml")}"
# #   ]
# #   set {
# #     name  = "cluster.enabled"
# #     value = "true"
# #   }
# }
