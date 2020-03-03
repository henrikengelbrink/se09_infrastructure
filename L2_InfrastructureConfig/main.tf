provider "digitalocean" {
  token = var.do_token
}

provider "google" {
  credentials = file(var.gcp_account_file_path)
  project     = var.gcloud_project
  region      = var.gcloud_region
}
