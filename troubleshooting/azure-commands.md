
# Handy commands Azure Kubernetes Cluster service

## Create resources and get kubectl context
`$ID = Get-Random -Minimum 1000 -Maximum 9999 ; $RG = "retail-haven-rg-$ID" ; $LOC = "uksouth" ; $CLUSTER_NAME = "aks-$RG" ; $DNS_LABEL = "dns-label-$RG" ; az group create --name $RG --location $LOC ; az aks create -g $RG --name $CLUSTER_NAME --enable-managed-identity --node-count 1 --generate-ssh-keys ; az aks get-credentials -g $RG --name $Cluster_NAME ; kubectl get nodes`

## Create a service principal for Github Action environment secret 
`az ad sp create-for-rbac --name "github-actions" --role contributor --scopes /subscriptions/<your subscription ID>/resourceGroups/retail-haven-rg-8366`

## Clean up the resources after use
`az group delete --name $RG --yes --no-wait`

This command deletes all Kubernetes resources, including the service principal, but not kubectl context on the local machine.  
![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/6a3b3a40-809d-480e-9a8c-e7cbc2350877)

`az ad sp list --display-name "Github-Actions" --query "{Name: displayName, ObjectId: objectId}"`
![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/5c734231-6ed9-455a-b9fd-8e6a8c533ff6)

## Clean up kubectl context on the local machine
`kubectl config delete-context aks-retail-haven-rg-8366`

