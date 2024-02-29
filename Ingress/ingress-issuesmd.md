  
  kubectl get pods -n development
  You should see cm-acme-http-solver if its stuck then secrobe 
  kubectl describe pod cm-acme-http-solver-p55ff -n argocd
  kubectl get certificate -n development
  kubectl describe certificate vpro-tls-secret -n development
  kubectl describe CertificateRequest vpro-tls-secret-1 -n development
  kubectl describe order vpro-tls-secret-1-3855979777 -n development
  kubectl describe Challenge vpro-tls-secret-1-3855979777-1847311768 -n development