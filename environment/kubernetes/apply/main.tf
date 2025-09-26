locals {
  # Read and split multi-doc YAML
  manifest_yaml   = replace(file(var.manifest_file), "\r\n", "\n")
  manifest_chunks = [for c in split("\n---\n", local.manifest_yaml) : c if trimspace(c) != ""]
  manifest_docs   = [for c in local.manifest_chunks : yamldecode(c)]

  # Stable keys: kind:namespace:name:index
  manifest_map = {
    for i, m in local.manifest_docs :
    "${lower(lookup(m, "kind", ""))}:${lookup(lookup(m, "metadata", {}), "namespace", "")}:${lookup(lookup(m, "metadata", {}), "name", "")}:${i}" => m
  }
}

resource "kubernetes_manifest" "apply" {
  for_each = local.manifest_map
  manifest = each.value

  wait { rollout = false }

  # tolerate existing objects (server-side apply)
  field_manager { force_conflicts = true }
}
