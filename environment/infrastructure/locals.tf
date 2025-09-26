locals {
  vpc_cidr_block = "10.0.0.0/16"
  azs            = slice(data.aws_availability_zones.available.names, 0, min(2, length(data.aws_availability_zones.available.names)))

  public_subnets  = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx + length(local.azs))]

  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)
  cluster_tag = {
    format("kubernetes.io/cluster/%s", local.vcluster_name) = "owned"
  }
  vpc_name           = format("%s-%s", local.vcluster_name, random_id.vpc_suffix.hex)

  node_role_name    = format("%s-node-role-%s", local.vcluster_name, random_id.vpc_suffix.hex)
  node_policy_name  = format("%s-node-policy-%s", local.vcluster_name, random_id.vpc_suffix.hex)
  node_profile_name = format("%s-node-profile-%s", local.vcluster_name, random_id.vpc_suffix.hex)
}
