#!/bin/sh

# Save current directory
CUR_DIR=$(pwd)

# Move to terraform directory
cd terraform

echo "Initializing Terraform..."
terraform init

echo "Applying Terraform configuration (this will start the Docker containers)..."
terraform apply -auto-approve

# Return to original directory
cd "$CUR_DIR"

echo "Terraform apply complete. Docker containers should be running." 