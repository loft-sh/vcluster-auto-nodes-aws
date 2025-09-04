data "aws_ssm_parameter" "ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "random_integer" "subnet_index" {
  min = 0
  max = length(var.vcluster.nodeEnvironment.outputs["private_subnet_ids"]) - 1
}

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.ami_id.insecure_value
  instance_type               = var.vcluster.nodeType.spec.properties["instance-type"]
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [var.vcluster.nodeEnvironment.outputs["security_group_id"]]
  user_data                   = var.vcluster.userData
  user_data_replace_on_change = true

  associate_public_ip_address = false

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = format("%s-worker-node", local.vcluster_name)
  }
}
