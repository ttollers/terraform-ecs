#!/usr/bin/env bash

# Zip lamda function
cd ./consumer
zip -FSrq lambda.zip .
mv lambda.zip ../launcher/

export TF_VAR_environment=$ENVIRONMENT_SUFFIX
export TF_VAR_application_name=$EB_APP_NAME
export TF_VAR_imageVersion=$DRONE_BUILD_NUMBER

# Set remote terraform state location
cd ../launcher
terraform remote config -backend=s3 -backend-config="bucket=tm-ep-tf-state" -backend-config="key=${EB_APP_NAME}_${ENVIRONMENT_SUFFIX}.tfstate" -backend-config="region=${AWS_REGION}" -backend-config="encrypt=true"

# Run terraform plan
terraform plan
terraform apply
