# terraform {
#   backend "remote" {
#     hostname = "app.terraform.io"
#     organization = "hengel2810"

#     workspaces {
#       name = "clothing-scanner"
#     }
#   }
# }

provider "digitalocean" {
  token = "${var.do_token}"
}

module "services" {
  source = "./services"
}
