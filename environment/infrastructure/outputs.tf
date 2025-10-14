output "vcluster_unique_name" {
  description = "A vCluster name with computed random 4 bytes hex"
  value       = local.vcluster_unique_name
}

output "private_subnet_ids" {
  description = "A list of private subnet ids"
  value       = module.vpc[local.region].private_subnets
}

output "public_subnet_ids" {
  description = "A list of public subnet ids"
  value       = module.vpc[local.region].public_subnets
}

output "security_group_id" {
  description = "Security group id to attach to worker nodes"
  value       = aws_security_group.workers.id
}

output "instance_profile_name" {
  description = "Instance profile name to attach to worker nodes"
  value       = aws_iam_instance_profile.vcluster_node.name
}

output "cluster_tag" {
  description = "Global tag of all provisioned AWS resources"
  value       = local.cluster_tag
}
