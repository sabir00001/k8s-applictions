cd ~/.kube
az group create --name aks-prod-rg --location eastus \
&& az aks create --resource-group aks-prod-rg --name aks-prod-cluster --node-count 1 --node-vm-size Standard_DS2_v2 \
                      --enable-addons monitoring \
                      --generate-ssh-keys \
                      --network-plugin azure --service-cidr 10.1.0.0/16 --dns-service-ip 10.1.0.10 --docker-bridge-address 172.17.0.1/16 \
                      --location eastus \
&& az aks get-credentials --resource-group aks-prod-rg --name aks-prod-cluster

# View kubeconfig
kubectl config view

# Configure AKSDEMO3 & 4 Cluster Access for kubectl
az aks get-credentials --resource-group rg-known-toad --name cluster-wanted-dinosaur

# View kubeconfig
kubectl config view

# View Cluster Information
kubectl cluster-info

# View the current context for kubectl
kubectl config current-context

# Switch Context
kubectl config use-context cluster-name

az aks show --resource-group aks-prod-rg --name aks-prod-cluster --query servicePrincipalProfile.clientId -o tsv

# Attach using acr-name
az aks update -n aks-prod-cluster -g  aks-prod-rg --attach-acr aksprodacr 

# Configure kubectl
az aks get-credentials --resource-group  aks-rg-prod --name aks-prod-cluster-01 --overwrite-existing

#To enable azure AD aks login
export KUBECONFIG=/path/to/kubeconfig
choco install kubernetes-cli azure-kubelogin

# Attach using acr-resource-id
az aks update -n aks-maf-dev-cluster -g aks-rg-dev --attach-acr aksprodacr
az aks update -n ${AKS_CLUSTER} -g ${AKS_RESOURCE_GROUP} --attach-acr aksprodacr

az network public-ip create --resource-group aks-rg-prod \
                            --name aksprodpipIngress \
                            --sku Standard \
                            --allocation-method static \
                            --query publicIp.ipAddress 
                            -o tsv

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

kubectl create namespace ingress-nginx

helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP="40.121.91.143" 



az group delete --name aaks-rg-prod --yes --no-wait