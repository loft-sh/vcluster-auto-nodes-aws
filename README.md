# vCluster Auto Nodes AWS

**td;dr**: I just need a `vcluster.yaml` to get started:

```yaml
# vcluster.yaml
controlPlane:
  service:
    spec:
     type: LoadBalancer
privateNodes:
  enabled: true
  autoNodes:
  - provider: aws-ec2
    dynamic:
    - name: aws-cpu-nodes
      nodeTypeSelector:
      - property: instance-type
        operator: In
        values: ["t3.medium", "t3.large", "t3.xlarge"]
```

## Overview

Terraform modules for provisioning **Auto Nodes on AWS**.  
These modules dynamically create EC2 instances as vCluster Private Nodes, powered by **Karpenter**.

### Key Features

- **Dynamic provisioning** – Nodes automatically scale up or down based on pod requirements  
- **Multi-cloud support** – Run vCluster nodes across AWS, GCP, Azure, on-premises, or bare metal  
  - CSI configuration in multi-cloud environments requires manual setup.
- **Cost optimization** – Provision only the resources you actually need  
- **Simple configuration** – Define node requirements directly in your `vcluster.yaml`  

By default, this quickstart **NodeProvider** isolates each vCluster into its own VPC.

---

## Resources Created Per Virtual Cluster

### [Infrastructure](./environment/infrastructure)

- A dedicated VPC  
- Public subnets in two Availability Zones  
- Private subnets in two Availability Zones  
- A NAT gateway for the private subnets  
- A security group for worker nodes  
- An IAM instance profile for worker nodes  
  - Permissions depend on whether CCM and CSI are enabled  

### [Kubernetes](./environment/kubernetes)

- Cloud Controller Manager for node initialization and automatic LoadBalancer creation  
- EBS CSI driver with a default storage class  
  - The default storage class does **not** enforce allowed topologies (important in multi-cloud setups). You can provide your own.  

### [Nodes](./node/)

- EC2 instances using the selected `instance-type`, attached to private subnets  

---

## Getting started

### Prerequisites

1. Access to an AWS account
2. A host kubernetes cluster, preferrably on AWS to use Pod Identity
3. vCluster Platform running in the host cluster. [Get started](https://www.vcluster.com/docs/platform/install/quick-start-guide)
4. (optional) The [vCluster CLI](https://www.vcluster.com/docs/vcluster/#deploy-vcluster)
5. (optional) Authenticate the vCluster CLI `vcluster platform login $YOUR_PLATFORM_HOST`

### Setup

#### Step 1: Configure Node Provider

Define your AWS Node Provider in the vCluster Platform. This provider manages the lifecycle of EC2 instances.

In the vCluster Platform UI, navigate to "Infra > Nodes", click on "Create Node Provider" and then use "AWS EC2".
Select a default region as a fallback. You can still specify the region per individual virtual cluster.

#### Step 2: Authenticate the Node Provider

Auto Nodes supports two authentication methods for AWS resources. **Pod Identity is strongly recommended** for production use.

##### Option A: Pod Identity (Recommended)

[Configure EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) to grant the vCluster control plane permissions to manage EC2 instances.
Then, assign the [the quickstart IAM policy](./docs/auto_nodes_policy.json) to your Pod Identity IAM Role to authenticate the terraform provider to create environments and nodes.

##### Option B: Manual secrets

If Pod Identity is not available, use a kubernetes secret with static credentials to authenticate against AWS.
You can create this secret from the vCluster Platform UI by choosing "specify credentials inline" in the Quickstart setup, or manually later on:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: aws-ec2-credentials
  namespace: vcluster-platform
  labels:
    terraform.vcluster.com/provider: "aws-ec2" # This has to match your provider name
stringData:
  AWS_ACCESS_KEY_ID: <your-access-key> 
  AWS_SECRET_ACCESS_KEY: <your-secret-key>
EOF
```

Ensure the IAM user has at least the permissions outlined in [the quickstart IAM policy](./docs/auto_nodes_policy.json).

#### Step 3: Create virtual cluster

This vcluster.yaml file defines a Private Node Virtual Cluster with Auto Nodes enabled. It exposes the control plane through an internet-facing nlb from an EKS host cluster. This is required for individual EC2 VMs to join the cluster.

```yaml
# vcluster.yaml
controlPlane:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    spec:
     type: LoadBalancer
privateNodes:
  enabled: true
  autoNodes:
  - provider: aws-ec2
    dynamic:
    - name: aws-cpu-nodes
      nodeTypeSelector:
      - property: instance-type
        operator: In
        values: ["t3.medium", "t3.large", "t3.xlarge"]
      limits:
        cpu: "100"
        memory: "200Gi"
```

Create the virtual cluster through the vCluster Platform UI or the vCluster CLI:

 `vcluster platform create vcluster aws-private-nodes -f ./vcluster.yaml --project default`

## Advanced configuration

### NodeProvider configuration options

You can configure the **NodeProvider** with the following options:

| Option                        | Default       | Description                                                                                 |
| ----------------------------- | ------------- | ------------------------------------------------------------------------------------------- |
| `vcluster.com/ccm-enabled`    | `true`        | Enables deployment of the Cloud Controller Manager.                                         |
| `vcluster.com/ccm-lb-enabled` | `true`        | Enables the CCM service controller. If disabled, CCM will not create LoadBalancer services. |
| `vcluster.com/csi-enabled`    | `true`        | Enables deployment of the CSI driver with a `<provider>-default-disk` storage class.                 |
| `vcluster.com/vpc-cidr`       | `10.0.0.0/16` | Sets the VPC CIDR range. Useful in multi-cloud scenarios to avoid CIDR conflicts.           |

## Example

```yaml
controlPlane:
  service:
    spec:
     type: LoadBalancer
privateNodes:
  enabled: true
  autoNodes:
  - provider: aws-ec2
    properties:
      vcluster.com/ccm-lb-enabled: "false"
      vcluster.com/csi-enabled: "false"
      vcluster.com/vpc-cidr: "10.10.0.0/16"
    dynamic:
    - name: aws-cpu-nodes
      nodeTypeSelector:
      - property: instance-type
        operator: In
        values: ["t3.medium", "t3.large", "t3.xlarge"]
```

## Security considerations

> **_NOTE:_** When deploying [Cloud Controller Manager (CCM)](https://kubernetes.io/docs/concepts/architecture/cloud-controller/) and [Container Storage Interface (CSI)](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/) with Auto Nodes, permissions are granted through instance profiles.
**This means all worker nodes inherit the same permissions as CCM and CSI.**
As a result, **any pod running with host networking in the cluster could potentially access the same cloud permissions**.
Refer to the full [list of permissions](environment/infrastructure/worker_iam.tf) for details.

Cluster administrators should be aware of the following:

- **Shared permissions** – all pods running in a **host network** may gain the same access level as CCM and CSI.  
- **Mitigation** – **Host networking for pods is disabled by default.**. Alternatively, cluster administrators can disable CCM and CSI deployments.  
  In that case, instance profiles will not be granted additional permissions.  
  However, responsibility for deploying and securely configuring CCM and CSI will then fall to the cluster administrator.  

> **_NOTE:_** Security-sensitive environments should carefully review which permissions are granted to clusters and consider whether CCM/CSI should be disabled and managed manually.

## Limitations

### Hybrid-cloud and multi-cloud

When running a vCluster across multiple providers, some additional configuration is required:

- **CSI drivers** – Install and configure the appropriate CSI driver for AWS cloud provider.  
- **StorageClasses** – Use `allowedTopologies` to restrict provisioning to valid zones/regions.  
- **NodePools** – Add topology-specific labels (e.g., `topology.ebs.csi.aws.com/zone`) so workloads are scheduled on nodes with matching storage availability.  

For details on multi-cloud setup, see the [Deploy](https://www.vcluster.com/docs/vcluster/deploy/worker-nodes/private-nodes/auto-nodes/quick-start-templates#deploy) and [Limits](https://www.vcluster.com/docs/vcluster/deploy/worker-nodes/private-nodes/auto-nodes/quick-start-templates#hybrid-cloud-and-multi-cloud) vCluster documentation.

#### Example: AWS Disk StorageClass with zones

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-gp3
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
allowedTopologies:
  - matchLabelExpressions:
      - key: topology.ebs.csi.aws.com/zone
        values: ["us-east-1a"]
```

### Region changes

Changing the region of an existing node pool is not supported.
To switch regions, create a new virtual cluster and migrate your workloads.

### Dynamic nodes `Limit`

When editing the limits property of dynamic nodes, any nodes that already exceed the new limit will **not** be removed automatically.
Administrators are responsible for manually scaling down or deleting the excess nodes.
