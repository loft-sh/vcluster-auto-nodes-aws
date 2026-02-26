locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  subnet_id         = "subnet-06a3185b09b262633" 
  instance_type     = var.vcluster.nodeType.spec.properties["instance-type"]
  user_data         = var.vcluster.userData
  security_group_id = "sg-040507668d1a31311" 
}
