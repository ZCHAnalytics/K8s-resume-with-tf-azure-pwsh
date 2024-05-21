

Create resources
```pwsh
$ID = Get-Random -Minimum 1000 -Maximum 9999 ; $RG = "ecommerce-rg-$ID" ; $LOC = "uksouth" ; $CLUSTER_NAME = "aks-$RG" ; $DNS_LABEL = "dns-label-$RG" ; az group create --name $RG --location $LOC ; az aks create -g $RG --name $CLUSTER_NAME --enable-managed-identity --node-count 1 --generate-ssh-keys ; az aks get-credentials -g $RG --name $Cluster_NAME ; kubectl get nodes
```

Clean up the resources after use
```pwsh
$RG = "ecommerce-rg-*" ; az group delete --name $RG --yes --no-wait
```