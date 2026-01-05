locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  subnet_id             = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_ids"][random_integer.subnet_index.result])
  instance_type         = nonsensitive(var.vcluster.nodeType.spec.properties["instance-type"])
  security_group_id     = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["security_group_id"])
  user_data             = var.vcluster.userData
  instance_profile_name = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["instance_profile_name"])
  cluster_tag           = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["cluster_tag"])
}
