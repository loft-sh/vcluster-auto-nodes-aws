terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "aws" {
  region = module.validation.region

  default_tags {
    tags = merge(
      local.cluster_tag,
      var.vcluster.instance != null ? {
        "vcluster:name"      = nonsensitive(var.vcluster.instance.metadata.name)
        "vcluster:namespace" = nonsensitive(var.vcluster.instance.metadata.namespace)
      } : {},
    )
  }
}
