data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_id" "vpc_suffix" {
  byte_length = 4
}

module "validation" {
  source = "./validation"
  region = var.vcluster.requirements["region"]
}

