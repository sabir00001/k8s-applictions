#!/bin/bash

# Path to the Terraform state file
terraform_state_file="$HOME/Desktop/DevOps/DevOps-Projects/Terraform/terraform.tfstate"

# Resource group name
resource_group_name="vproapp-rg"

# Fetch Azure resources
az_resources=$(az resource list --resource-group $resource_group_name --output json)
echo "Azure Resources:"
echo "$az_resources" 

# Fetch Terraform state
terraform_state=$(terraform show -json $terraform_state_file)
echo "Terraform State:"
echo "$terraform_state" 

# Parse Azure resources and Terraform state
az_resource_ids=($(echo "$az_resources" | jq -r '.[].id'))
terraform_resource_ids=($(echo "$terraform_state" | jq -r '.values.root_module.resources[].id'))

# Compare resources
echo "Comparing Resources:"
result="Comparison Result:\n"
for az_resource_id in "${az_resource_ids[@]}"
do
    found=false
    for terraform_resource_id in "${terraform_resource_ids[@]}"
    do
        if [[ "$terraform_resource_id" == *"$az_resource_id"* ]]; then
            echo "Resource with ID $az_resource_id found in Terraform state"
            result+="Resource with ID $az_resource_id found in Terraform state\n"
            found=true
            break
        fi
    done
    if [ "$found" == "false" ]; then
        echo "Resource with ID $az_resource_id not found in Terraform state"
        result+="Resource with ID $az_resource_id not found in Terraform state\n"
    fi
done

echo -e "$result" > comparison_result.txt