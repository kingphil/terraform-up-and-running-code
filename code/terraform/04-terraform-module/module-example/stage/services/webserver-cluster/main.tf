terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "kubernetes" {}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  ## pek: ok, I don't get how terraform.tfvars is supposed to work
  replica_size = 2
  image_version = "1.18.0"
}
