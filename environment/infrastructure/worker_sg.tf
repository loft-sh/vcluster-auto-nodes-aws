resource "aws_security_group" "workers" {
  name        = format("%s-workers-sg", local.vcluster_unique_name)
  description = "Security group for worker nodes: allow intra-VPC traffic, kubelet, NodePort, and outbound internet"
  vpc_id      = module.vpc[local.region].vpc_id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic within the VPC for CNI and node-to-node communication
  ingress {
    description = "intra-vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_cidr_block]
  }

  # Kubelet API
  ingress {
    description = "kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  # NodePort range (internal)
  ingress {
    description = "nodeport-range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  # SSH within VPC (admins should use bastion or restricted CIDR in production)
  ingress {
    description = "ssh-from-vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  # Kubernetes API
  ingress {
    description = "kubernetes-api"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  # ICMP
  ingress {
    description = "icmp"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  # Flannel VXLAN (default backend)
  ingress {
    description = "flannel-vxlan"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  tags = {
    name = format("%s-workers-sg", local.vcluster_unique_name)
  }
}
