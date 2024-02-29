Unable to create application: application spec for emart is invalid: InvalidSpecError: application destination server 'https://kubernetes.default.svc' and namespace 'emart-dev' do not match any of the allowed destinations in project 'emart-app'

kubectl get ns argocd -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/argocd/finalize" -f -


I loved this answer extracted from here

In one terminal:

kubectl proxy
In another terminal:

kubectl get ns delete-me -o json | \
  jq '.spec.finalizers=[]' | \
  curl -X PUT http://localhost:8001/api/v1/namespaces/delete-me/finalize -H "Content-T

  argocd cluster add  kubernetes-admin@kubernetes --server argo.sabirch.shop:443
  login argo.sabirch.shop:443 --grpc-web


  https://github.com/MuhammedKalkan/OpenLens/releases/download/v6.5.2-366/OpenLens.Setup.6.5.2-366.exe

  $url = "https://github.com/argoproj/argo-cd/releases/download/" + v2.10.1 + "/argocd-windows-amd64.exe"
$output = "argocd.exe"

Invoke-WebRequest -Uri $url -OutFile $output