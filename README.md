# Kubernetes Resume Challenge - a Windows Version (with a dose of troubleshooting)

This is my take on the Kubernetes Resume Challenge using Terraform, Helm, Azure and Powershell. The Challenge is prepared by people behind CLoud Resume Challenge and KodeKloud Academy. JOin the challenge here: https://cloudresumechallenge.dev/docs/extensions/kubernetes-challenge/

The project was seemingly prepared for Linux environment, so I added an extra complexity by opting for a Windows environment and Powershell. This required some extra [windows troubleshooting](windows-troubleshooting). I also added extra step to use Terraform to make project closer to real-life scenarios where IaaS deployment are used. 

# Pre-requisites 
Azure, Kubectl, Docker, Terraform, Helm CLI, attention to CRLF and LF, source code from KodeKloud, and a bucketfull of sheer willpower... 

## Terrraform 
I used Terraform to combined the creation of Azure Kubernetes Cluster, one pod for a MariaDB server and another one for Apache server to host website called "Retail Heaven".
For specifics, please check this folder [terraform](terraform).

![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/f732f709-77dd-44e8-89f8-bc0b8e986f17)

## Helm 
Using Helm was an extra credit! So I helmified all yaml files and created a chart that used Azure Kubernetes Cluster to configure environmentla variables, create database, new user with full privileges to create table 'products' and populate it with values. The end result is the retail website! You can check my helm files here [helm](helm).

## CI/CD with GitHub Workflows
- GitHub secrets and tokens 
[.github/workflows](.github/workflows/deploy.yml)

## and all the steps prior to this point... 
Prior to deploying Infrastructure as a Code, the challenge involved step by step process of configuring and testing progressively growing components as listed below: 
- Creating Dockerfile for Apache server with the relevant expensions 
- Azure Kubernetes Cluster creation (CLI)
- Kubernetes service files for internal and external connections
- Secrets for storing sensitive data
- configMaps for toggles
- Kubernetes deployment files for MariaDB database and apache server
- Updating source code in Dockerfile to include dark-mode style, toggle features and a promotional banner for marketing campaign. 
- Scaling the application, rolling back the deployment, testing liveliness and readiness
- Creating persistent storage for the database.  
  
## Step 1: Certification
KodeKloud offers the Certified Kubernetes Application Developer (CKAD) course to equip developers with the knowledge and skills needed to tackle this challenge effectively. 
I am very keen to get a Kubernetes certification, as soon as I finished preparing for the Terraform Associate exam! Watch this space.... 

## Step 2: Tasks - Containerise E-Commerce Website and Database
- [x] Create a Dockerfile with php:7.4-apache base image, mysqli extension, the application source code.
- [x] Update database connection strings to point to a Kubernetes service named mysql-service.
- [x] Build and Push the Docker Image
- [x] Database Containerization

Implementation:
First, I copied the source code from Kode Kloud GitHub repository [link https://github.com/kodekloudhub/learning-app-ecommerce] to the project directory (as an archive, without cloning the repository itself):
  ```pwsh
  & { mkdir abundant_source ; cd abundant_source ; curl -sL <link>/archive/master.tar.gz | tar -xzf - --strip-components=1 } | Out-Null
  ```
Second, I located a php file called index.php that uses a mysqli function to connect to the database using cluster variables. I just tidied up the code, indentation and compressed it a bit (for better readability and future troubleshooting). I made a note of how mysqli function retrives database variables and used these names for Kubernetes service and secrets. This way, the apache container can interpolate the values from the cluster environment in oeprating the database in a separate container.

As for the Docker image, I used a more recent php-apache version for the Dockerfile, hoping it will integrate better with kubectl and mariadb versions I use. I also added pdo packages to give the container ability to run SQl commands. 

`docker build -t zulfia/<your-chosen-image-name-for-posterity>:v1 .`  
`docker push zulfia/<your-chosen-image-name-for-posterity>:v1`

The last task in this Step was to configure database containerisation. I place the sql script in the php deployment file, instead of the mariadb deployment file thus avodiging the use of ConfigMap. 

<Note on Windows: As I am using Windows and containers run on linux, I need to make sure that  the relevant files have LF ending instead of CRLF. There are many ways of doing so as shown here <link> but usually git converts them automatically when adding. To avoid a lot of commit messages, i occassionally converted files in the powershell terminal directly. 
<Note on Windows: As Docker Engine runs on Ubuntu, I also have to run WSL which can takes up more memory. As as soon as I push the image, I close stop Docker Desktop.

## Step 3. Set up Kubernetes on a Public Cloud Provider
- [x] Cluster creation.

I created a command to simplify the creation of an Azure Kubernetes Cluster. This command creates environmental variables and then the necessary resources in one go, leaving me free to go away and grate some ginger for tea.
```pwsh
$ID = Get-Random -Minimum 1000 -Maximum 9999 ; $RG = "ecommerce-rg-$ID" ; $LOC = "uksouth" ; $CLUSTER_NAME = "aks-$RG" ; $DNS_LABEL = "dns-label-$RG" ; az group create --name $RG --location $LOC ; az aks create -g $RG --name $CLUSTER_NAME --enable-managed-identity --node-count 1 --generate-ssh-keys ; az aks get-credentials -g $RG --name $Cluster_NAME ; kubectl get nodes
```
## Step 4: Deploy E-commerce Website to Kubernetes
- [x] 4.1. Kubernetes deployment 

I am asked to hardcode the root password and the password for the new future user. It is a bit cringe-inducing but somehow adding secrets at a later stage (Step 12) proved to be complicated. So I am happy to tried both options and observed how differently processes worked. So, now the e-commerce web application is running on Kubernetes, with pods managed by the Deployment.
To test, lets enterthe container and run some commands:

![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/a80ebcca-5b73-4010-af0f-5bfa3d95c91b)

## Step 5: Expose Your Website [v]
- [x] Service creation with Load Balancer

We could choose to do this step via CLI command or a yaml file. 
Via CLI
```pwsh
kubectl expose deploy/deploy-retail-therapy --port 80 --target-port 80 --type LoadBalancer --name=php-service
service/php-service exposed
```
![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/93e1fd2b-9230-4e50-b3a6-6143d1f7f478)

For second option, which is an external service yaml, check this [service file](5a-svc-web.yaml)

When the database connection does not work, website will show and error of some sort, like this one:

![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/11081575-ae0b-463f-8bd7-11f450345641)

< Troubleshooting: turned out i needed to change the commands from mysql to mariadb inside the mariadb container and also change the Dockerfile to add mysql client and mysql server in addition to mysqli client. That added 300mb more of disk size but build time was still around the same. 

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/1e4c4301-3355-420f-bf73-1cf34a692a89)

## Step 6: Implement Configuration Management by add a feature toggle
- [x] Modify the Web Application: Add a simple feature toggle in the application code (e.g., an environment variable FEATURE_DARK_MODE that enables a CSS dark theme).
- [x] Use ConfigMaps: Create a ConfigMap named feature-toggle-config with the data FEATURE_DARK_MODE=true.
- [x] Deploy ConfigMap: Apply the ConfigMap to your Kubernetes cluster.
- [x] Update Deployment: Modify the website-deployment.yaml to include the environment variable from the ConfigMap.
- [x] Then we need to add a 'simple feature toggle' in the application code (e.g., an environment variable FEATURE_DARK_MODE that enables a CSS dark theme). 

It turns out it was not 'simple' at all. First of all, I am not at all familiar with php code. Coincidentally, my teenage kid had asked for help with html and css project at school, and got me second wings to learn website building languages at speed. Secondly, the instructions implied that the dark mode code existed somewhere in the source code. So the 'simple' solution' was not working even with increasing troubleshooting complexity. I had to assume that project code was based on no longer functioning github links and create a truly simple css code. 

If I set the toggle to false and re-apply configmap and deploy again, the website reverts to default light background. 

## Step 7: Scale Web Application to prepare for a marketing campaign expected to triple traffic.
- [x] Evaluate Current Load: Use kubectl get pods to assess the current number of running pods.
- [x] Scale Up: Increase replicas in deployment or use kubectl scale deployment/ecom-web --replicas=6 to handle the increased load.
- [x] Monitor Scaling: Observe the deployment scaling up with kubectl get pods.

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/8213670e-9e45-45bb-81ed-4b4b75b768e5)

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/b74cdbc1-f1a9-4412-8795-93f30ba9e78f)

## Step 8: Perform a Rolling Update to include a new promotional banner for the marketing campaign.
- [x]    Update Application: Modify the web application’s code to include the promotional banner.
- [x]    Build and Push New Image.
- [x]    Rolling Update: Update website-deployment.yaml with the new image version and apply the changes.
- [x]    Monitor Update: Use kubectl rollout status deployment/ecom-web to watch the rolling update process.

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/67bc7793-10ee-46b7-b845-0600c4122734)

## Step 9: Roll back to the previous version.
- [x] Identify Issue: After deployment, monitoring tools indicate a problem affecting user experience.
- [x] Roll Back: Execute kubectl rollout undo deployment/ecom-web to revert to the previous deployment state.
- [x] Verify Rollback: Ensure the website returns to its pre-update state without the promotional banner.

## Step 10: Autoscale Your Application based on CPU usage to handle unpredictable traffic spikes.
- [x]  Implement HPA: Create a Horizontal Pod Autoscaler targeting 50% CPU utilization, with a minimum of 2 and a maximum of 10 pods.
- [x]  Apply HPA: Execute kubectl autoscale deployment ecom-web --cpu-percent=50 --min=2 --max=10.
- [x]  Simulate Load: Use a tool like Apache Bench to generate traffic and increase CPU load.
- [x]  Monitor Autoscaling: Observe the HPA in action with `kubectl get hpa`.

before:
![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/96861b3c-d5cd-4663-8eb3-eaabbd0af441)

after:
![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/02fc18a4-1f97-4c15-8a05-7eed9eb8ddf6)

```
kubectl autoscale deployment a-pod-for-retail-therapy --cpu-percent=50 --min=2 --max=10
ab -n 100 -c 10 URL
```
Check [12-4-7-autoscale.yaml](autoscale yaml file). 

## Step 11: Implement Liveness and Readiness Probes to ensure the web application is restarted if it becomes unresponsive and doesn’t receive traffic until ready.
- [x]    Define Probes: Add liveness and readiness probes to website-deployment.yaml, targeting an endpoint in application that confirms its operational status.
- [x]    Apply Changes: It worked! 
- [x]    Test Probes: Simulate failure scenarios (e.g., manually stopping the application) and observe Kubernetes’ response. 

Again, I searched the soure code direcotry for any endpoint, health, live, ready to find none. So i created status.php file with a configmap and changed the deployment file.

## Step 12: Utilize ConfigMaps and Secrets
- [x]    Create Secret and ConfigMap: For sensitive data like DB credentials, use a Secret. For non-sensitive data like feature toggles, use a ConfigMap.
- [x]    Update Deployment: Reference the Secret and ConfigMap in the deployment to inject these values into the application environment.

Finally, I can work with secrets and stop cringing....
generate base64 code:
```bash
echo -n "spillYourBeans" | base64
```
USEFUL COMMANDS:
kubectl exec -it <pod_name> -- /bin/bash
mysql -u <username> -p<password>-uro
SELECT User FROM mysql.user;
mysql -u simplymaria -p

## Step 13: Document Your Process in GitHub
- [x]    Push Your Code to the Remote Repository
- [x]    Write Documentation: Create a README.md or a blog post detailing each step, decisions made, and how challenges were overcome.

## Extra credit - Package Everything in Helm
- [x] Create Helm Chart: Start by creating a Helm chart for your application. This involves setting up a chart directory with the necessary templates for your Kubernetes resources.
- [x] Define Values: Customize your application deployment by defining variables in the values.yaml file. This allows for flexibility and reusability of your Helm chart across different environments or configurations.
- [x] Package and Deploy: Use Helm commands to package your application into a chart and deploy it to your Kubernetes cluster. Ensure to test your chart to verify that all components are correctly configured and working as expected.
```
helm create retail-therapy-app
```
## Extra credit - Implement Persistent Storage for the MariaDB database across pod restarts and redeployments.
- [x] Create a PVC: Define a PersistentVolumeClaim for MariaDB storage needs.
- [x] Update MariaDB Deployment: Modify the deployment to use the PVC for storing database data.

## Extra credit - Implement Basic CI/CD Pipeline
- [] GitHub Actions Workflow.

Create a .github/workflows/deploy.yml file to build the Docker image, push it to Docker Hub, and update the Kubernetes deployment upon push to the main branch.

Cheats: as kubectl config can be rather large, good to check what is in there

```pwsh
kubeConfig = kubectl config view --minify --context=aks-retail-rg-5603
base64EncodedConfig = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($kubeConfig))
base64EncodedConfig
```




## Project Directory 

🌍  Project Directory Tree
├───dockerfilewithbanner
│   └───source-code
│       ├───css
|       |   ├───dark-mode.css # new file for dark-mode 
|       └───index.php # with added promotional banner and dark mode toggle
├───helm
│   ├───retail-therapy-app
│   |   ├───templates/
│   |   ├───Chart.yaml
│   |   ├───values.yaml
|   └───secrets.yaml
├───step2-12-plus-extra
└───terraform
