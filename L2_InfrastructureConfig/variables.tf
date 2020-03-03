variable "do_token" {}

variable "k8s_cluster_name" {
  default = "se09-cluster"
}

variable "postgres_cluster_name" {
  default = "se09-cluster"
}

variable "cluster_domain" {
  default = "engelbrink.dev"
}

variable "gcp_account_file_path" {}
variable "gcloud_project" {}
variable "gcloud_region" {}
