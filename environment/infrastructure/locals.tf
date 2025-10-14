locals {
  region = nonsensitive(var.vcluster.properties["region"])
  azs    = slice(data.aws_availability_zones.available.names, 0, min(2, length(data.aws_availability_zones.available.names)))

  public_subnets  = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx + length(local.azs))]

  vcluster_name        = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_unique_name = format("%s-%s", local.vcluster_name, random_id.suffix.hex)
  vcluster_namespace   = nonsensitive(var.vcluster.instance.metadata.namespace)

  cluster_tag = {
    format("kubernetes.io/cluster/%s", local.vcluster_name) = "owned"
  }

  vpc_cidr_block = try(var.vcluster.properties["vcluster.com/vpc-cidr"], "10.0.0.0/16")
  ccm_enabled    = try(tobool(var.vcluster.properties["vcluster.com/ccm-enabled"]), true)
  csi_enabled    = try(tobool(var.vcluster.properties["vcluster.com/csi-enabled"]), true)
}
