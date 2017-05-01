#!/usr/bin/env bash

export TF_VAR_ENVIRONMENT=dev
export TF_VAR_CLUSTER_NAME=test-ecs
export TF_VAR_VPC_ID=vpc-871d38e3
export TF_VAR_SSH_KEY_NAME=ep

# Run terraform plan
terraform plan
terraform apply

