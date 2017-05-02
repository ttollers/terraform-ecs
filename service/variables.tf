
variable "REGION" {
  default = "eu-west-1"
}

variable "SERVICE_NAME" {
  default = "hello-world"
}

variable "ENVIRONMENT" {
  default = "dev"
}

variable "CLUSTER_NAME" {
  default = "ecs-cluster"
}

variable "ACCOUNT_NUMBER" {}

variable "VPC_ID" {}

variable "LB_SUBNETS" {
  type = "list"
  default = [
    "subnet-ecefc79a",
    "subnet-a481b5c0",
    "subnet-a481b5c0"
  ]
}

variable "IMAGE_NAME" {
  default = "crccheck/hello-world"
}

variable "CONTAINER_PORT" {
  default = 8080
}
