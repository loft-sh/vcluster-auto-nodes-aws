locals {
  vpc_cidr_block = "10.0.0.0/16"
  azs            = data.aws_availability_zones.available.names

  public_subnets  = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx + length(local.azs))]

  vcluster_name = nonsensitive(var.vcluster.name)
  region        = nonsensitive(var.vcluster.requirements["region"])
  vpc_name      = format("%s-%s", local.vcluster_name, random_id.vpc_suffix.hex)
}
