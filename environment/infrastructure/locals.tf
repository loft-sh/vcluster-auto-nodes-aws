locals {
  region = nonsensitive(var.vcluster.properties["region"])
  azs    = slice(data.aws_availability_zones.available.names, 0, min(2, length(data.aws_availability_zones.available.names)))

  public_subnets  = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx + length(local.azs))]

  # The network environment is cluster-scoped and shared by every vCluster that uses it
  network_environment_name = nonsensitive(var.vcluster.name)

  vpc_cidr_block = nonsensitive(try(var.vcluster.properties["vcluster.com/vpc-cidr"], "10.0.0.0/16"))
  ccm_enabled    = nonsensitive(try(tobool(var.vcluster.properties["vcluster.com/ccm-enabled"]), true))
  csi_enabled    = nonsensitive(try(tobool(var.vcluster.properties["vcluster.com/csi-enabled"]), true))
}
