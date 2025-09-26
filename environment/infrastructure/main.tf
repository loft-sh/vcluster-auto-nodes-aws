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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.vpc_name
  cidr = local.vpc_cidr_block

  azs                    = local.azs
  private_subnets        = local.private_subnets
  public_subnets         = local.public_subnets
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Name = local.vpc_name
  }
}

