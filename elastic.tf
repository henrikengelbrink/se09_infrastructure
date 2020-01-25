# https://www.linode.com/docs/applications/containers/how-to-deploy-the-elastic-stack-on-kubernetes/

data "helm_repository" "helm_repo_elastic" {
    name = "elastic"
    url  = "https://helm.elastic.co"
}

resource "helm_release" "elasticsearch_cluster" {
    name = "elasticsearch"
    repository = "${data.helm_repository.helm_repo_elastic.metadata.0.name}"
    chart = "elastic/elasticsearch"
    namespace = "elastic"
    timeout = 600
    set {
      name  = "replicas"
      value = 2
    }
    depends_on = [
      "kubernetes_cluster_role_binding.tiller",
      "kubernetes_service_account.tiller",
      "kubernetes_namespace.k8s_namespace_elastic"
    ]
}

resource "helm_release" "filebeat" {
    name = "filebeat"
    repository = "${data.helm_repository.helm_repo_elastic.metadata.0.name}"
    chart = "elastic/filebeat"
    namespace = "elastic"
    timeout = 600
    depends_on = [
      "helm_release.elasticsearch_cluster"
    ]
}

resource "helm_release" "kibana" {
    name = "kibana"
    repository = "${data.helm_repository.helm_repo_elastic.metadata.0.name}"
    chart = "elastic/kibana"
    namespace = "elastic"
    timeout = 600
    depends_on = [
      "helm_release.filebeat"
    ]
}

resource "helm_release" "metricbeat" {
    name = "metricbeat"
    repository = "${data.helm_repository.helm_repo_elastic.metadata.0.name}"
    chart = "elastic/metricbeat"
    namespace = "elastic"
    timeout = 600
    depends_on = [
      "helm_release.kibana"
    ]
}

resource "null_resource" "metricbeat_dashboards" {
  provisioner "local-exec" {
    command = "./scripts/metricbeat-dashboards.sh"
  }
  depends_on = [
    "helm_release.metricbeat"
  ]
}
