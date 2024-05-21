Install Kubernetes CLI [v]
```pwsh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```
![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/e3aef431-6b64-4b00-8758-d017e0776646)


# Check the installation of packages inthe php container:

kubectl exec -it a-pod-for-retail-therapy-7bffb776d9-fl2x6 -- mariadb --version
kubectl exec -it a-pod-for-retail-therapy-7bffb776d9-fl2x6 -- mysql --version
kubectl exec -it a-pod-for-retail-therapy-7bffb776d9-fl2x6 -- mysqli --version

# Explore the file structure of php container
kubectl exec -it <pod-name> -- /bin/bash

To use a specific shell, such as sh, replace /bin/bash with /bin/sh or any other shell available within the container.

# Copy files between local file system and the pod

kubectl cp <pod-name>:/path/to/pod/file /local/path

## Expose apache web  
kubectl expose deploy/deploy-retail-therapy --port 80 --target-port 80 --type LoadBalancer --name=php-service
service/php-service exposed

## create configmap
kubectl create configmap php-config --from-file=/index-with-toggle.php


# useful commands for troubleshooting mariadb container
🌈  kubectl exec -it deploy-retail-database-776d9b469f-kctbk -- bash -c 'mariadb -u root -p < /docker-entrypoint-initdb.d/enter_the_dragon.sql'

💯  kubectl exec -it deploy-retail-database-776d9b469f-kctbk -- bash -c 'mariadb -u root -p -e "SELECT User FROM mysql.user;"'


kubectl exec <database pod hash> -- mariadb -uroot -pgrowYourRoots -e "select version()"
kubectl exec <database pod hash> -- mariadb -u simply_maria -pspillYourBeans -e "show databases"

# create database 
kubectl exec deploy-retail-therapy-7b56dcbd67-kkfx6 -c mariadb -- mariadb -uroot -psecret -e "create database if not exists simplydatabase; show databases;" 



# Supress apache warning :

the Apache warnings about not being able to determine the server's fully qualified domain name are common and can be ignored in most cases, especially for local development or testing environments. 

To suppress these messages, set the 'ServerName' directive in your Apache configuration file (httpd.conf).


# cli commands for database creation
```
kubectl exec deploy-retail-therapy-7b56dcbd67-kkfx6 -c mariadb -- mariadb -uroot -psecret -e "select version()"
````
![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/3775eaf1-87f1-4148-a1df-42beb15916e3)

# then create a database called simplydatabase:
```
kubectl exec deploy-retail-therapy-7b56dcbd67-kkfx6 -c mariadb -- mariadb -uroot -psecret -e "create database if not exists simplydatabase; show databases;" 
```
![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/bc926615-6536-440b-ab88-7d6d559d0ab6)


# change index
then run CLI command to modify the index.php file inside the deployed php container:

```pwsh
kubectl create configmap php-config --from-file=/index-with-toggle.php
```

# find feature mode toggle
kubectl exec -it <pod_name> -- env | findstr FEATURE_DARK_MODE


# onliners
 kubectl delete configmaps and-sky-configured-maria && kubectl delete deploy a-pod-for-maria && kubectl apply -f 12-2-cm-db.yaml && kubectl apply -f 12-3-dp-db.yaml && kubectl get pods