data "helm_repository" "datawire" {
  name = "datawire"
  url  = "https://www.getambassador.io"
}

resource "helm_release" "ambassador" {
  repository = data.helm_repository.datawire.metadata.0.name
  name       = "ambassador"
  chart      = "datawire/ambassador"
  version    = "v6.2.2"
  namespace  = "default"
  set {
    name  = "image.tag"
    value = "1.3.1"
  }
}

resource "null_resource" "load_balancer_delay" {
  provisioner "local-exec" {
    command = "./scripts/load-balancer.sh"
  }
  depends_on = [
    helm_release.ambassador
  ]
}

resource "null_resource" "ambassador_api" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=default apply -f ./crds/ambassador-api.yml"
  }
  depends_on = [
    helm_release.ambassador
  ]
}

resource "null_resource" "ambassador_example" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=default apply -f ./crds/ambassador-example.yml"
  }
  depends_on = [
    helm_release.ambassador
  ]
}

resource "null_resource" "ambassador_mqtt" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=default apply -f ./crds/ambassador-mqtt.yml"
  }
  depends_on = [
    helm_release.ambassador
  ]
}
