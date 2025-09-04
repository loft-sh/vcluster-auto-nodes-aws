data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_id" "vpc_suffix" {
  byte_length = 4
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.vpc_name
  cidr = local.vpc_cidr_block

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true

  one_nat_gateway_per_az = true

  tags = {
    Name = local.vpc_name
  }
}

