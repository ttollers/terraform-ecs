# ECS Cluster and Service Example

A parameterized working example of AWS ECS using Terraform.

## Cluster:

```
cd cluster
terraform plan
terraform apply
```

Terraform Variables:

| Name   | Default      | Description |
|--------|:------------:|------------:|
| CLUSTER_NAME | ecs-cluster | Name of the cluster |
| ENVIRONMENT | dev | Name of the environment |
| SSH_KEY_NAME | NONE | The AWS key pair name for ssh |
| VPC_ID | - | The vpc id where the cluster will be located |

## ECS Service

Add a container based service to the cluster.

```
cd service
terraform plan
terraform apply
```

| Name   | Default      | Description |
|--------|:------------:|------------:|
| SERIVCE_NAME | hello-world | Name of the Service |
| CLUSTER_NAME | ecs-cluster | Name of the clustern the service will be added to |
| ENVIRONMENT | dev | Name of the environment |
| VPC_ID | - | The vpc id where the cluster will be located |
| ACCOUNT_NUMBER | - | The AWS Account number the cluster is located in |

#TODO
Vertical Scaling
Use terraform loop for scale-ups / scale-downs
Improve security
Parameterize missing vars
