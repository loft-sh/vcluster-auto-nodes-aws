locals {
  ccm_enabled    = try(tobool(var.vcluster.properties["vcluster.com/ccm-enabled"]), true)
  ccm_lb_enabled = try(tobool(var.vcluster.properties["vcluster.com/ccm-lb-enabled"]), true)
  csi_enabled    = try(tobool(var.vcluster.properties["vcluster.com/csi-enabled"]), true)

  availability_zones = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["availability_zones"])

  node_provider_name = nonsensitive(var.vcluster.nodeProvider.metadata.name)
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)

  suffix = substr(md5(format("%s%s", local.node_provider_name, local.vcluster_name)), 0, 8)
}
