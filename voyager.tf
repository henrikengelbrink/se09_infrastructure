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

resource "kubernetes_secret" "acme_secret_k8s" {
  metadata {
    name = "acme-account"
    namespace = "voyager"
  }
  data = {
    ACME_EMAIL = "hengel2810@gmail.com"
    ACME_SERVER_URL = "https://acme-staging-v02.api.letsencrypt.org/directory"
  }
  depends_on = [
    "local_file.kubeconfig",
    "helm_release.voyager_ingress_controller"
  ]
}

resource "kubernetes_secret" "dns_digital_ocean_secret_k8s" {
  metadata {
    name = "do-dns-secret"
    namespace = "voyager"
  }
  data = {
    DO_AUTH_TOKEN = "${var.do_token}"
  }
  depends_on = [
    "kubernetes_secret.acme_secret_k8s"
  ]
}

resource "null_resource" "ingress" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./kubeconfig.yaml --namespace=voyager apply -f ./k8s_crd/voyager-ingress.yml"
  }
  depends_on = [
    "kubernetes_secret.acme_secret_k8s"
  ]
}

# resource "kubernetes_ingress" "ingress" {
#   metadata {
#     name = "main-ingress"
#     namespace = "voyager"
#     annotations = {
#       "ingress.appscode.com/type" = "LoadBalancer"
#       "kubernetes.io/ingress.class" = "voyager-ingress"
#     }
#   }
#   spec {
#     backend {
#       service_name = "terraform-example-app"
#       service_port = 80
#     }
#     tls {
#       secret_name = "cert-main-domain"
#       hosts = [
#         "example.engelbrink.dev",
#         "mqtt.engelbrink.dev",
#         "kiali.engelbrink.dev"
#       ]
#     }
#     rule {
#       host = "example.engelbrink.dev"
#       http {
#         path {
#           path = "/"
#           backend {
#             service_name = "terraform-example-app"
#             service_port = 80
#           }
#         }
#       }
#     }
#     rule {
#       host = "mqtt.engelbrink.dev"
#       tcp {
#         path {
#           path = "/"
#           backend {
#             service_name = "vernemq-cluster"
#             service_port = 80
#           }
#         }
#       }
#     }
#   }
#   depends_on = [
#     "kubernetes_secret.acme_secret_k8s"
#   ]
#     # - host: mqtt.engelbrink.dev
#     # tcp:
#     #   port: 8883
#     #   backend:
#     #     serviceName: vernemq-cluster.mqtt
#     #     servicePort: 1883
# }

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
