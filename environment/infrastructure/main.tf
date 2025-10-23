data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "validation" {
  source = "./validation"
  region = local.region
}

module "vpc" {
  # Keep VPC as map to trigger the whole module recreation in case of region change
  for_each = { (local.region) = true }

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.0"

  name = format("vcluster-vpc-%s", random_id.suffix.hex)
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
    name = format("vcluster-vpc-%s", random_id.suffix.hex)
  }
}
