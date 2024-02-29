#!/bin/bash

# Path to the Terraform state file
terraform_state_file="path/to/terraform.tfstate"

# Resource group name
resource_group_name="your_resource_group_name"

# Fetch Azure resources
az_resources=$(az resource list --resource-group $resource_group_name --output json)
echo "Azure Resources:"
echo "$az_resources" > azure_resources.txt

# Fetch Terraform state
terraform_state=$(terraform show -json $terraform_state_file)
echo "Terraform State:"
echo "$terraform_state" > terraform_state.txt

# Parse Azure resources and Terraform state
az_resource_names=($(echo "$az_resources" | jq -r '.[].name'))
terraform_resource_names=($(echo "$terraform_state" | jq -r '.values.root_module.resources[].name'))

# Compare resources
echo "Comparing Resources:"
result="Comparison Result:\n"
for az_resource_name in "${az_resource_names[@]}"
do
    found=false
    for terraform_resource_name in "${terraform_resource_names[@]}"
    do
        if [[ "$terraform_resource_name" == *"$az_resource_name"* ]]; then
            echo "Resource $az_resource_name found in Terraform state"
            result+="Resource $az_resource_name found in Terraform state\n"
            found=true
            break
        fi
    done
    if [ "$found" == "false" ]; then
        echo "Resource $az_resource_name not found in Terraform state"
        result+="Resource $az_resource_name not found in Terraform state\n"
    fi
done

echo -e "$result" > comparison_result.txt
