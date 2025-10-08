locals {
  manifest_files = [
    "${path.module}/manifests/admission-policy.yaml.tftpl",
    "${path.module}/manifests/ccm.yaml.tftpl",
    "${path.module}/manifests/csi.yaml.tftpl",
  ]
  template_vars = {
    node_provider_name = nonsensitive(var.vcluster.nodeProvider.metadata.name)
  }
}

locals {
  files_indexed = { for i, f in local.manifest_files : i => f }
}
module "manifests" {
  source        = "./apply"
  for_each      = local.files_indexed
  manifest_file = each.value
  template_vars = local.template_vars
}
