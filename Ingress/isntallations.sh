az aks update -n aks-maf-dev-cluster -g aks-rg-dev --attach-acr aksprodacr
az aks update -n ${AKS_CLUSTER} -g ${AKS_RESOURCE_GROUP} --attach-acr aksprodacr

az network public-ip create --resource-group aks-rg-prod \
                            --name aksprodpipIngress \
                            --sku Standard \
                            --allocation-method static \
                            --query publicIp.ipAddress 
                            -o tsv

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm search repo ingress-nginx -l
#https://learn.microsoft.com/en-us/azure/aks/ingress-basic?tabs=azure-cli#create-an-ingress-controller

helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP="172.190.216.211" 


