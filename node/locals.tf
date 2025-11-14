locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  subnet_id         = "subnet-0de0bead18530989b" 
  instance_type     = var.vcluster.nodeType.spec.properties["instance-type"]
  user_data         = var.vcluster.userData
  security_group_id = "sg-025366b7fd8a56586" 
}
