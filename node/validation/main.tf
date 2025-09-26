variable "region" {
  type        = string
  description = "The AWS region"
}

locals {
  region = nonsensitive(split(",", var.region)[0])
}

resource "null_resource" "validate" {
  lifecycle {
    precondition {
      condition     = length(trimspace(local.region)) > 0
      error_message = "Region cannot be empty. Please provide a valid AWS region."
    }

    precondition {
      condition     = local.region != "*" && !can(regex("[*?\\[\\]{}]", local.region))
      error_message = "Region cannot be a glob pattern or contain wildcards. Received: '${local.region}'"
    }
  }
}

output "region" {
  value = local.region
}
