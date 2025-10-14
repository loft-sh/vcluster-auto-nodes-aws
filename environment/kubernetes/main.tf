locals {
  ccm_enabled = try(tobool(var.vcluster.properties["vcluster.com/ccm-enabled"]), true)
  csi_enabled = try(tobool(var.vcluster.properties["vcluster.com/csi-enabled"]), true)

  node_provider_name = nonsensitive(var.vcluster.nodeProvider.metadata.name)
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
}

module "kubernetes_apply_admission_policy" {
  source = "./apply"

  manifest_file = "${path.module}/manifests/admission-policy.yaml.tftpl"
  template_vars = {
    node_provider_name = local.node_provider_name
  }
}

module "kubernetes_apply_ccm" {
  source = "./apply"

  for_each = local.ccm_enabled ? { "enabled" = true } : {}

  manifest_file = "${path.module}/manifests/ccm.yaml.tftpl"
  template_vars = {
    node_provider_name = local.node_provider_name
    vcluster_name      = local.vcluster_name
  }
}

module "kubernetes_apply_csi" {
  source = "./apply"

  for_each = local.csi_enabled ? { "enabled" = true } : {}

  manifest_file = "${path.module}/manifests/csi.yaml.tftpl"
  template_vars = {
    node_provider_name = local.node_provider_name
  }
}
