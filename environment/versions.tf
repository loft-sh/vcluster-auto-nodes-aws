terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      "vcluster:name"      = var.vcluster.instance.metadata.name
      "vcluster:namespace" = var.vcluster.instance.metadata.namespace
    }
  }
}
