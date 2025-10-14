locals {
  vcluster_name        = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_unique_name = var.vcluster.nodeEnvironment.outputs.infrastructure["vcluster_unique_name"]
  vcluster_namespace   = nonsensitive(var.vcluster.instance.metadata.namespace)

  subnet_id             = var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_ids"][random_integer.subnet_index.result]
  instance_type         = var.vcluster.nodeType.spec.properties["instance-type"]
  security_group_id     = var.vcluster.nodeEnvironment.outputs.infrastructure["security_group_id"]
  user_data             = var.vcluster.userData
  instance_profile_name = var.vcluster.nodeEnvironment.outputs.infrastructure["instance_profile_name"]
  cluster_tag           = var.vcluster.nodeEnvironment.outputs.infrastructure["cluster_tag"]
}
