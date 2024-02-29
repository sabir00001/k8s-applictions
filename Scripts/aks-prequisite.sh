# Variables
AKS_RESOURCE_GROUP=aks-rg-prod
AKS_REGION="eastus"

AKS_VNET=aks-vnet-prod
AKS_VNET_ADDRESS_PREFIX=10.0.0.0/8
AKS_VNET_SUBNET_DEFAULT=aks-subnet-prod-default
AKS_VNET_SUBNET_DEFAULT_PREFIX=10.240.0.0/16
AKS_VNET_SUBNET_VIRTUALNODES=aks-subnet-prod-virtual-nodes
AKS_VNET_SUBNET_VIRTUALNODES_PREFIX=10.241.0.0/16

AKSADMIN_GROUP="aks-prod-admins"
AKS_AD_AKSADMIN1_USER="aksadmin01"
AKS_AD_AKSADMIN1_USER_PASSWORD="P@ssw0rd123@sam123"
AZURE_DEFAULT_AD_DOMAIN="sabirchoudhuryyahoo.onmicrosoft.com"

AKS_WINDOWS_NODE_USERNAME="azureuser"
AKS_WINDOWS_NODE_PASSWORD="P@ssw0rd1234sam123"
AKS_WORKSPACE_ID="aks-prod-logs-01"

AKS_CLUSTER=aks-prod-cluster-01
# Step-02: Pre-requisite-1: Create Resource Group
echo $AKS_RESOURCE_GROUP, $AKS_REGION
az group create --location ${AKS_REGION} \
                --name ${AKS_RESOURCE_GROUP}

# Step-02: Pre-requisite-2: Create Azure Virtual Network and Two Subnets
echo $AKS_VNET, $AKS_VNET_ADDRESS_PREFIX, $AKS_VNET_SUBNET_DEFAULT, $AKS_VNET_SUBNET_DEFAULT_PREFIX, $AKS_VNET_SUBNET_VIRTUALNODES, $AKS_VNET_SUBNET_VIRTUALNODES_PREFIX

# Create Virtual Network & default Subnet
az network vnet create -g ${AKS_RESOURCE_GROUP} \
                       -n ${AKS_VNET} \
                       --address-prefix ${AKS_VNET_ADDRESS_PREFIX} \
                       --subnet-name ${AKS_VNET_SUBNET_DEFAULT} \
                       --subnet-prefix ${AKS_VNET_SUBNET_DEFAULT_PREFIX}

# Create Virtual Nodes Subnet in Virtual Network
az network vnet subnet create --resource-group ${AKS_RESOURCE_GROUP} \
                               --vnet-name ${AKS_VNET} \
                               --name ${AKS_VNET_SUBNET_VIRTUALNODES} \
                               --address-prefixes ${AKS_VNET_SUBNET_VIRTUALNODES_PREFIX}

# Get Virtual Network default subnet id
AKS_VNET_SUBNET_DEFAULT_ID=$(az network vnet subnet show --resource-group ${AKS_RESOURCE_GROUP} \
                                                         --vnet-name ${AKS_VNET} \
                                                         --name ${AKS_VNET_SUBNET_DEFAULT} \
                                                         --query id \
                                                         -o tsv)
echo ${AKS_VNET_SUBNET_DEFAULT_ID}

# Step-02: Pre-requisite-3: Create Azure AD Group & Admin User
AKS_AD_AKSADMIN_GROUP_ID=$(az ad group create --display-name ${AKSADMIN_GROUP} \
                                               --mail-nickname ${AKSADMIN_GROUP} \
                                               --query id \
                                               -o tsv)
#group_info=$(az ad group show --group ${AKSADMIN_GROUP})
#group_id=$(echo "$group_info" | jq -r '.id')
echo $AKS_AD_AKSADMIN_GROUP_ID

AKS_AD_AKSADMIN1_USER_OBJECT_ID=$(az ad user create --display-name ${AKS_AD_AKSADMIN1_USER} \
                                                     --user-principal-name ${AKS_AD_AKSADMIN1_USER}@${AZURE_DEFAULT_AD_DOMAIN} \
                                                     --password ${AKS_AD_AKSADMIN1_USER_PASSWORD} \
                                                     --query id \
                                                     -o tsv)

echo $AKS_AD_AKSADMIN1_USER_OBJECT_ID 

az ad group member add --group ${AKSADMIN_GROUP} --member-id $AKS_AD_AKSADMIN1_USER_OBJECT_ID

# Step-04: Pre-requisite-4: Create SSH Key
mkdir $HOME/.ssh/aks-prod-sshkeys

ssh-keygen -m PEM -t rsa -b 4096 -C "azureuser@myserver" \
            -f ~/.ssh/aks-prod-sshkeys/aksprodsshkey \
            -N mypassphrase

ls -lrt $HOME/.ssh/aks-prod-sshkeys

AKS_SSH_KEY_LOCATION=($HOME/.ssh/aks-prod-sshkeys/aksprodsshkey.pub)
echo $AKS_SSH_KEY_LOCATION

# Step-05: Pre-requisite-5: Create Log Analytics Workspace
AKS_MONITORING_LOG_ANALYTICS_WORKSPACE_ID=$(az monitor log-analytics workspace create \
                                           --resource-group ${AKS_RESOURCE_GROUP} \
                                           --workspace-name ${AKS_WORKSPACE_ID} \
                                           --query id \
                                           -o tsv)
echo $AKS_MONITORING_LOG_ANALYTICS_WORKSPACE_ID

# Step-06: Pre-requisite-5: Get Azure AD Tenant ID and Set Windows Username Passwords
az aks get-versions --location ${AKS_REGION} -o table

AZURE_DEFAULT_AD_TENANTID=$(az account show --query tenantId --output tsv)
echo $AZURE_DEFAULT_AD_TENANTID

AKS_WINDOWS_NODE_USERNAME=azureuser
AKS_WINDOWS_NODE_PASSWORD="P@ssw0rd1234!234"
echo $AKS_WINDOWS_NODE_USERNAME, $AKS_WINDOWS_NODE_PASSWORD


# Create AKS cluster 
az aks create --resource-group ${AKS_RESOURCE_GROUP} \
              --name ${AKS_CLUSTER} \
              --enable-managed-identity \
              --generate-ssh-keys \
              --ssh-key-value  ${AKS_SSH_KEY_LOCATION} \
              --admin-username aksnodeadmin \
              --node-count 1 \
              --enable-cluster-autoscaler \
              --min-count 1 \
              --max-count 100 \
              --network-plugin azure \
              --service-cidr 10.0.0.0/16 \
              --dns-service-ip 10.0.0.10 \
              --docker-bridge-address 172.17.0.1/16 \
              --vnet-subnet-id "${AKS_VNET_SUBNET_DEFAULT_ID}" \
              --enable-aad \
              --aad-admin-group-object-ids a440eb92-17ab-4a76-a5ca-967da24cf569 \
              --aad-tenant-id ${AZURE_DEFAULT_AD_TENANTID} \
              --windows-admin-password "P@ssw0rd123@sam123" \
              --windows-admin-username ${AKS_WINDOWS_NODE_USERNAME} \
              --node-osdisk-size 30 \
              --node-vm-size Standard_DS2_v2 \
              --nodepool-labels nodepool-type=system nodepoolos=linux app=system-apps \
              --nodepool-name systempool \
              --nodepool-tags nodepool-type=system nodepoolos=linux app=system-apps \
              --enable-addons monitoring \
              --workspace-resource-id ${AKS_MONITORING_LOG_ANALYTICS_WORKSPACE_ID} \
              --enable-ahub \
              --zones {1,2,3}

az network public-ip create --resource-group aks-maf-control-rg-prod \
                            --name aksprodIPIngress \
                            --sku Standard \
                            --allocation-method static \
                            --query publicIp.ipAddress 
                            -o tsv
kubectl create namespace ingress-nginx

helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP="13.68.178.191" 


az aks nodepool add --resource-group ${AKS_RESOURCE_GROUP} \
                    --cluster-name ${AKS_CLUSTER} \
                    --name userapp \
                    --node-count 1 \
                    --enable-cluster-autoscaler \
                    --max-count 2 \
                    --min-count 1 \
                    --mode User \
                    --node-vm-size Standard_DS2_v2 \
                    --os-type Linux \
                    --labels nodepool-type=user environment=production nodepoolos=linux app=user-apps \
                    --tags nodepool-type=user environment=production nodepoolos=linux app=user-apps \
                    --zones {1,2,3}