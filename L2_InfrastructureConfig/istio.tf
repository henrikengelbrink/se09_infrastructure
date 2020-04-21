resource "null_resource" "istio_operator" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=default apply -f https://istio.io/operator.yaml"
  }
}

resource "null_resource" "istio_plane" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml --namespace=default apply -f ./crds/istio-plane.yml"
  }
  depends_on = [
    null_resource.istio_operator
  ]
}
