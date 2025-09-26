# vCluster Auto Nodes AWS

**td;dr**: I just need a `vcluster.yaml` to get started:

```yaml
# vcluster.yaml
controlPlane:
  advanced:
    cloudControllerManager:
      enabled: false # disable vcluster CCM
  service:
    spec:
     type: LoadBalancer

privateNodes:
  enabled: true
  autoNodes:
    dynamic:
    - name: aws-cpu-nodes
      provider: aws-ec2
      requirements:
      - property: instance-type
        operator: In
        values: ["t3.medium", "t3.large", "t3.xlarge"]
```

## Overview

Terraform modules for Auto Nodes on AWS to dynamically provision EC2 instances for vCluster Private Nodes using Karpenter.

- Dynamic provisioning - Nodes scale up/down based on pod requirements
- Multi-cloud support: Works across public clouds, on-premises, and bare metal
- Cost optimization - Only provision the exact resources needed
- Simplified configuration - Define node requirements in your vcluster.yaml

This quickstart NodeProvider isolates all nodes into separate VPCs by default.

Per virtual cluster, it'll create (see [Environment](./environment/infrastructure)):

- A VPC
- A public subnet in 2 AZs
- A private subnet in 2 AZs
- One NAT gateway attached to the private subnets
- A security group for the worker nodes

Per virtual cluster, it'll create (see [Node](./node/)):

- An EC2 instance with the selected `instance-type`, attached to one of the private Subnets

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
  advanced:
    cloudControllerManager:
      enabled: false # disable vcluster CCM
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    spec:
     type: LoadBalancer

privateNodes:
  enabled: true
  autoNodes:
    dynamic:
    - name: aws-cpu-nodes
      provider: aws-ec2
      requirements:
      - property: instance-type
        operator: In
        values: ["t3.medium", "t3.large", "t3.xlarge"]
      limits:
        cpu: "100"
        memory: "200Gi"
```

Create the virtual cluster through the vCluster Platform UI or the vCluster CLI:

 `vcluster platform create vcluster aws-private-nodes -f ./vcluster.yaml --project default`

## Resource Cleanup Before Cluster Removal

When decommissioning a cluster, it is important that all resources created by **Cloud Controller Manager (CCM)** and **Container Storage Interface (CSI)** are cleaned up manually.  
This includes, but is not limited to:

- **CCM-managed resources**
  - Services

- **CSI-managed resources**
  - PersistentVolumes (PVs)

Failure to perform this cleanup may result in **orphaned cloud resources**.
