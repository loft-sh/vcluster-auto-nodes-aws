# CPU nodes use Ubuntu 22.04 LTS
data "aws_ami" "cpu" {
  count       = local.is_gpu_node ? 0 : 1
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# GPU nodes use Deep Learning Base AMI with pre-installed NVIDIA drivers
data "aws_ami" "gpu" {
  count       = local.is_gpu_node ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04) *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  ami_id = local.is_gpu_node ? data.aws_ami.gpu[0].id : data.aws_ami.cpu[0].id
}

module "validation" {
  source = "./validation"
  region = var.vcluster.properties["region"]
}

resource "random_integer" "subnet_index" {
  min = 0
  max = length(var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_ids"]) - 1
}

resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = local.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [local.security_group_id]
  user_data                   = local.user_data
  user_data_replace_on_change = true

  associate_public_ip_address = false

  root_block_device {
    volume_size           = local.disk_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  private_dns_name_options {
    hostname_type = "resource-name"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1 # Restrict IMDS to host network
  }

  iam_instance_profile = local.instance_profile_name

  tags = {
    name = format("%s-worker-node", local.vcluster_name)
  }
}
