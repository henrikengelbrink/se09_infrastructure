terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "hengel2810"

    workspaces {
      name = "se_09"
    }
  }
}

provider "digitalocean" {
  token = "${var.do_token}"
}
