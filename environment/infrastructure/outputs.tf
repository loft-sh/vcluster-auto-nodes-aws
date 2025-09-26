output "private_subnet_ids" {
  description = "A list of private subnet ids"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "A list of public subnet ids"
  value       = module.vpc.public_subnets
}

output "security_group_id" {
  description = "Security group id to attach to worker nodes"
  value       = aws_security_group.workers.id
}

output "instance_profile_name" {
  description = "Instance profile name to attach to worker nodes"
  value       = aws_iam_instance_profile.allow_ccm_csi_ecr.name
}

output "cluster_tag" {
  description = "Global tag of all provisioned AWS resources"
  value       = local.cluster_tag
}
