terraform {
  backend "s3" {
    bucket  = "${local.vcluster_name}-tfstate"
    key     = "node/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
