locals {
  vcluster_name = nonsensitive(var.vcluster.name)
  region        = nonsensitive(var.vcluster.requirements["region"])
  subnet_id     = var.vcluster.nodeEnvironment.outputs["private_subnet_ids"][random_integer.subnet_index.result]
}
