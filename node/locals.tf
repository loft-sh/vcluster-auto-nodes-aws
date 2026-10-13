locals {
  # var.vcluster.instance is null for NodeClaims without a vCluster, name and namespace are always set
  vcluster_name      = nonsensitive(var.vcluster.name)
  vcluster_namespace = nonsensitive(var.vcluster.namespace)

  # vCluster names are only unique per namespace and workers share the network environment,
  # so the cluster ID combines both. It must match the CCM --cluster-name flag.
  cluster_id = format("%s-%s", substr(local.vcluster_name, 0, 40), substr(md5(format("%s/%s", local.vcluster_namespace, local.vcluster_name)), 0, 8))

  cluster_tag = {
    format("kubernetes.io/cluster/%s", local.cluster_id) = "owned"
  }

  infrastructure = var.vcluster.networkEnvironment.outputs.infrastructure

  subnet_id             = nonsensitive(local.infrastructure["private_subnet_ids"][random_integer.subnet_index.result])
  instance_type         = nonsensitive(var.vcluster.nodeType.spec.properties["instance-type"])
  security_group_id     = nonsensitive(local.infrastructure["security_group_id"])
  user_data             = var.vcluster.userData != "" ? var.vcluster.userData : null
  instance_profile_name = nonsensitive(local.infrastructure["instance_profile_name"])
}
