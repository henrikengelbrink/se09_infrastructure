resource "null_resource" "istio_operator" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./kubeconfig.yaml apply -f https://istio.io/operator.yaml"
  }
  depends_on = [
    "local_file.kubeconfig"
  ]
}

resource "null_resource" "istio_plane" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./kubeconfig.yaml apply -f ./k8s_crd/istio-plane.yml"
  }
  depends_on = [
    "null_resource.istio_operator"
  ]
}
