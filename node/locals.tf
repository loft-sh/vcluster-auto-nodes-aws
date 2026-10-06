locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  cluster_tag = {
    format("kubernetes.io/cluster/%s", local.vcluster_name) = "owned"
  }

  infrastructure = var.vcluster.networkEnvironment.outputs.infrastructure

  subnet_id             = nonsensitive(local.infrastructure["private_subnet_ids"][random_integer.subnet_index.result])
  instance_type         = nonsensitive(var.vcluster.nodeType.spec.properties["instance-type"])
  security_group_id     = nonsensitive(local.infrastructure["security_group_id"])
  user_data             = var.vcluster.userData != "" ? var.vcluster.userData : null
  instance_profile_name = nonsensitive(local.infrastructure["instance_profile_name"])
}
