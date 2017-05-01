#!/usr/bin/env bash

export TF_VAR_ENVIRONMENT=dev
export TF_VAR_SERVICE_NAME=test-service
export TF_VAR_CLUSTER_NAME=test-ecs-dev
export TF_VAR_ACCOUNT_NUMBER=247237293916
export TF_VAR_VPC_ID=vpc-871d38e3

# Run terraform plan
terraform plan
terraform apply
