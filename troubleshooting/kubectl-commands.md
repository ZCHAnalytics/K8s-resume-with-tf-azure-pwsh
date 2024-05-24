# Handy commands when troubleshooting

One-liners: 

`kubectl delete configmaps <config name> && kubectl delete deploy <deploy name> && kubectl apply -f <config.yaml> && kubectl apply -f <deploy.yaml> && kubectl get pods`

## Apache container

Explore the file structure of the php container: 

`kubectl exec -it <pod name with hash> -- /bin/bash`

Check the installation of packages in the php container:

`kubectl exec -it <pod name with hash> -- mysqli --version`

Expose Apache web with Load Balancer `

`kubectl expose deploy/<deploy name> --port 80 --target-port 80 --type LoadBalancer --name=<service name>`

Check if feature mode toggle exists

`kubectl exec -it <pod name with hash> -- env | grep FEATURE_DARK_MODE`

Create configmap for toggle

`kubectl create configmap <config name> --from-file=/<index-with-toggle>.php`


##  MariaDB container: 
```
kubectl exec -it <pod anme with hash> -- bash -c 'mariadb -u root -p' 
kubectl exec pod <pod name with hash> -c mariadb -- mariadb -uroot -psecret -e "create database if not exists simplydatabase; show databases;"
```
![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/bc926615-6536-440b-ab88-7d6d559d0ab6)
