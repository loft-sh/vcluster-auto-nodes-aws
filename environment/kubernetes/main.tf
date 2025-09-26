locals {
  manifest_files = [
    "${path.module}/manifests/admission-policy.yaml",
    "${path.module}/manifests/ccm.yaml",
    "${path.module}/manifests/csi.yaml",
  ]
}

# Preserve order
locals {
  files_indexed = { for i, f in local.manifest_files : i => f }
}
module "manifests_ordered" {
  source        = "./apply"
  for_each      = local.files_indexed
  manifest_file = each.value
}
