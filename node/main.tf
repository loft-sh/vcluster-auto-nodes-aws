terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  ami_id = try(var.vcluster.requirements["ami_id"], data.aws_ami.ubuntu.id)
}


provider "aws" {
  region = var.vcluster.requirements["region"]

  default_tags {
    tags = {
      "vcluster:name"      = var.vcluster.instance.metadata.name
      "vcluster:namespace" = var.vcluster.instance.metadata.namespace
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^al2023-ami-2023.*-x86_64"
}

# VM
resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.vcluster.nodeType.spec.properties["instance-type"]
  subnet_id                   = var.vcluster.nodeEnvironment.outputs["private_subnet_id"]
  vpc_security_group_ids      = [var.vcluster.nodeEnvironment.outputs["security_group_id"]]
  user_data                   = var.vcluster.userData
  user_data_replace_on_change = true

  # --- Root disk sizing ---
  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.vcluster.name}-ec2"
  }
}
