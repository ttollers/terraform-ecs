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
| LB_SUBNETS | - | The list of subnets that the loadbalancer can be in |
| IMAGE_NAME | crccheck/hello-world | The container image name |
| CONTAINER_PORT | 8080 | The exposed port of the container |


#TODO
Vertical Scaling
Use terraform loop for scale-ups / scale-downs
Improve security
Parameterize missing vars
Add container based iam roles
