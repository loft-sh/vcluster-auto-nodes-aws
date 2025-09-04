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
