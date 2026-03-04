locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  subnet_id             = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_ids"][random_integer.subnet_index.result])
  instance_type         = nonsensitive(var.vcluster.nodeType.spec.properties["instance-type"])
  security_group_id     = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["security_group_id"])
  user_data             = var.vcluster.userData != "" ? var.vcluster.userData : null
  instance_profile_name = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["instance_profile_name"])
  cluster_tag           = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["cluster_tag"])

  # GPU properties from node type
  disk_size = try(tonumber(nonsensitive(var.vcluster.nodeType.spec.properties["disk-size"])), 100)

  # NVIDIA GPU instance families: p3 (V100), p4d/p4de (A100), p5/p5e (H100),
  # g4dn (T4), g5 (A10G), g6/g6e (L4), gr6 (L4)
  is_gpu_node = can(regex("^(p[3-6]|g4dn|g[5-6]|gr6)", local.instance_type))
}
