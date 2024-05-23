# Handy commands when troubleshooting

One-liners: 

`kubectl delete configmaps and-sky-configured-maria && kubectl delete deploy a-pod-for-maria && kubectl apply -f <file.yaml> && kubectl apply -f <file2.yaml> && kubectl get pods`

## Apache container

Explore the file structure of the php container: 

`kubectl exec -it <pod-name> -- /bin/bash`

Check the installation of packages in the php container:

`kubectl exec -it a-pod-for-retail-therapy-7bffb776d9-fl2x6 -- mysqli --version`

Expose Apache web with Load Balancer `

kubectl expose deploy/deploy-retail-therapy --port 80 --target-port 80 --type LoadBalancer --name=php-service`

Check if feature mode toggle exists

`kubectl exec -it <pod_name> -- env | grep FEATURE_DARK_MODE`

Create configmap for toggle

`kubectl create configmap php-config --from-file=/index-with-toggle.php`


##  MariaDB container: 
```
kubectl exec -it deploy-retail-database-776d9b469f-kctbk -- bash -c 'mariadb -u root -p' 
kubectl exec deploy-retail-therapy-7b56dcbd67-kkfx6 -c mariadb -- mariadb -uroot -psecret -e "create database if not exists simplydatabase; show databases;"
```
![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/bc926615-6536-440b-ab88-7d6d559d0ab6)
