#!/usr/bin/env bash

export TF_VAR_environment=dev
export TF_VAR_application_name=test-service
export TF_VAR_CLUSTER_NAME=test-ecs-dev

# Run terraform plan
terraform plan
terraform apply
