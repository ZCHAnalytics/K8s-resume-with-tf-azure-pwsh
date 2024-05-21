# Kubernetes Resume Challenge - a Windows Version (with a heavy dose of troubleshooting)

This is my take on the Kubernetes Resume Challenge using Terraform, Helm, Azure and Powershell. The Challenge is prepared by people behind CLoud Resume Challenge and KodeKloud Academy. JOin the challenge here: https://cloudresumechallenge.dev/docs/extensions/kubernetes-challenge/

The project was simimgly prepared for Linux environment, so I added an extra complexity by opting Windows environment and Powershell. This required some extra steps for troubleshooting. 

I also added extra step to use terraform as using helm only to deploy web server and database to make project closer to real-life scenarios where IaaS deployment are used. 

# Pre-requisites 
Azure, Kubectl, Docker, Terraform, Helm CLI
ability to convert CRLF to LF
source code from KodeKloud

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

## Terrraform 
I used Terraform to combined the creation of Azure Kubernetes Cluster, pod with a MariaDB serverand a pod with Apache server to host website called "Retail Heaven".
For specifics, please check this folder [terraform](terraform).

## Helm 
Using Helm was an extra credit, so I helmified all yaml files and created a chart that used Azure Kubernetes Cluster to configure environmentla variables, create database, new user with full privileges to create table 'products' and populate it with values. The end result is the retail website! 

## Background work 

Prior to deploying Infrastructure as a Code, the challenge involved step by step process of configuring and testing progressivley complex assets. These steps are outlined below. 

## Step 1: Certification
I am very keen to get a Kubernetes certification, as soon as I finished preparing for the Terraform Associate exam! Watch this space.... 

## Step 2: Containerise E-Commerce Website and Database
- [x] 2.1  Copy the pre-configured web application code into the project directory

The code is provided by the KodeKloud for this challenge in their github repo. This command copies the git repository as web source code (not as repository):
  ```pwsh
  & { mkdir abundant_source ; cd abundant_source ; curl -sL <link>/archive/master.tar.gz | tar -xzf - --strip-components=1 } | Out-Null
  ```
- [x] 2.2  Locate and check the configuration file for connection method to database
  I localted a php file called index.php that uses a mysqli function to connect to the database using cluster variables. I made a note of how variables should be named for correct interpolation: DB_HOST, DB_USER, DB_NAME, DB_PASSWORD.

- [x] 2.3  Configure Dockerfile for web app
  I created an initial Dockerfile tagged as version 1 that contained mysqli extension for apache server to make the connection to the database. Additionally, I had to add other database packages as I decided to perform all SQL oepration from within the apache container. I just tidied up the code, indentation and compressed it a bit (for better readability and future troubleshooting). I also opted for a more recent version of an Apache image to make sure it worked with more up-to-date mariadb and kubectl.

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/afcf462b-53ef-44fc-b4bc-41d836d404f1)

<Note on Windows: As I am using Windows and containers run on linux, I need to make sure that  the relevant files have LF ending instead of CRLF. There are many ways of doing so as shown here <link> but usually git converts them automatically when adding. To avoid a lot of commit messages, i occassionally converted files in the powershell terminal directly. 

Then from the project directory Dockerfile is ready to be built! 
```pwsh
docker build -t zulfia/<your-chosen-image-name-for-posterity>:v1 .
docker push zulfia/<your-chosen-image-name-for-posterity>:v1
```
<Note on Windows: As Docker Engine runs on Ubuntu, I also have to run WSL which can takes up more memory. As as soon as I push the image, I close stop Docker Desktop.

- [x] 3.2. Create a Kubernetes cluster on Azure
Before I resorted to Tterraform, I created a one line command to simplify the creation of an Azure Kubernetes Cluster. This command creates environmental variables and then the necessary resources in one go, while I could grate some ginger for tea.
```pwsh
$ID = Get-Random -Minimum 1000 -Maximum 9999 ; $RG = "ecommerce-rg-$ID" ; $LOC = "uksouth" ; $CLUSTER_NAME = "aks-$RG" ; $DNS_LABEL = "dns-label-$RG" ; az group create --name $RG --location $LOC ; az aks create -g $RG --name $CLUSTER_NAME --enable-managed-identity --node-count 1 --generate-ssh-keys ; az aks get-credentials -g $RG --name $Cluster_NAME ; kubectl get nodes
```
Outcome in Azure portal:

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/7b1e5ded-edc2-49c2-a91f-cd007b78757d)

## Step 4: Deploy E-commerce Website to Kubernetes

- [x] 4.1. Configure website and mariadb deployment files
  I am asked to hardcode the root password and the password for the new future user. It is a bit cringe-inducing but somehow adding secrets at a later stage (Step 12) proved to be complicated. So I am happy to tried both options and observed how differently processes worked. 
- [x] 4.2. Apply the configuration
  So, now the e-commerce web application is running on Kubernetes, with pods managed by the Deployment.

  To test, lets create a sample database:
  ```pwsh
  kubectl exec <pod-hash mariadb> -- mariadb -uroot -pspillYourBeans -e "create database if not exists k8s; show databases;"
  ```
  ![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/a80ebcca-5b73-4010-af0f-5bfa3d95c91b)

## Step 5: Expose Your Website [v]
We could choose to do this step via CLI command or a yaml file. I am sharing both ways here: 
Via CLI
```pwsh
kubectl expose deploy/deploy-retail-therapy --port 80 --target-port 80 --type LoadBalancer --name=php-service
service/php-service exposed
```
![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/93e1fd2b-9230-4e50-b3a6-6143d1f7f478)

For second option, which is an external service yaml, check this [service file](5a-svc-web.yaml)

Website is not public but the mysqli link to a backend database does not work, so theraputic effect of my retail sit is not yet possible. 

![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/11081575-ae0b-463f-8bd7-11f450345641)

< Troubleshooting: turned out i needed to change the commands from mysql to mariadb inside the mariadb container and also change the Dockerfile to add mysql client and mysql server in addition to mysqli client. That added 300mb more of disk size but build time was still around the same. 

Again, this is an option of creating the database with CLI command. However, I wanted keep a nice orderly sequence of yaml files. The CLI steps are in this <file>

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/1e4c4301-3355-420f-bf73-1cf34a692a89)

## Step 6: Implement Configuration Management by add a feature toggle

Then we need to add a 'simple feature toggle' in the application code (e.g., an environment variable FEATURE_DARK_MODE that enables a CSS dark theme). 
Dark mode themes make websites accessible, with sufficiently thought-through featues, so I am glad I got to work on a toggle feature. 

It turns out it was not 'simple' at all. First of all, I am not at all familiar with php code. Coincidentally, my teenage kid had asked for help with html and css project at school, and got me second wings to learn website building languages at speed.

Secondly, the instructions implied that the dark mode code existed somewhere in the source code. So the 'simple' solution' was not working even with increasing troubleshooting complexity. I had to assume that project code was based on no longer functioning github links and create a truly simple css code. 

The website should now render in dark mode, demonstrating how ConfigMaps manage application features. The websites loads in dark mode even on mobile screen with text inverting to white to maintain contrat with the dark background.

If I set the toggle to false and re-apply configmap and deploy again, the website reverts to default light background. 

## Step 7: Scale Web Application
Task: Prepare for a marketing campaign expected to triple traffic.
- [] Evaluate Current Load: Use kubectl get pods to assess the current number of running pods.
  ![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/8213670e-9e45-45bb-81ed-4b4b75b768e5)

- [] Scale Up: Increase replicas in deployment or use kubectl scale deployment/ecom-web --replicas=6 to handle the increased load.
![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/b74cdbc1-f1a9-4412-8795-93f30ba9e78f)

- [] Monitor Scaling: Observe the deployment scaling up with kubectl get pods.

## Step 8: Perform a Rolling Update

Task: Update the website to include a new promotional banner for the marketing campaign.

- [x]    Update Application: Modify the web application’s code to include the promotional banner.

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/67bc7793-10ee-46b7-b845-0600c4122734)

- [x]    Build and Push New Image.
- [x]    Rolling Update: Update website-deployment.yaml with the new image version and apply the changes.
- [x]    Monitor Update: Use kubectl rollout status deployment/ecom-web to watch the rolling update process.
- [x]    Outcome: The website updates with zero downtime, demonstrating rolling updates’ effectiveness in maintaining service availability.

## Step 9: Roll Back a Deployment
Task: Suppose the new banner introduced a bug. Roll back to the previous version.

- [x] Identify Issue: After deployment, monitoring tools indicate a problem affecting user experience.
- [x] Roll Back: Execute kubectl rollout undo deployment/ecom-web to revert to the previous deployment state.
- [x] Verify Rollback: Ensure the website returns to its pre-update state without the promotional banner.
- [x] Outcome: The application’s stability is quickly restored, highlighting the importance of rollbacks in deployment strategies.

## Step 10: Autoscale Your Application
Task: Automate scaling based on CPU usage to handle unpredictable traffic spikes.

- [x] Implement HPA: Create a Horizontal Pod Autoscaler targeting 50% CPU utilization, with a minimum of 2 and a maximum of 10 pods.
- [x]    Apply HPA: Execute kubectl autoscale deployment ecom-web --cpu-percent=50 --min=2 --max=10.
- [x]    Simulate Load: Use a tool like Apache Bench to generate traffic and increase CPU load.

before:
![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/96861b3c-d5cd-4663-8eb3-eaabbd0af441)

after:
![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/02fc18a4-1f97-4c15-8a05-7eed9eb8ddf6)

```
kubectl autoscale deployment a-pod-for-retail-therapy --cpu-percent=50 --min=2 --max=10
ab -n 100 -c 10 URL
```
Check [12-4-7-autoscale.yaml](autoscale yaml file). 

- [x]    Monitor Autoscaling: Observe the HPA in action with `kubectl get hpa`.

## Step 11: Implement Liveness and Readiness Probes
Task: Ensure the web application is restarted if it becomes unresponsive and doesn’t receive traffic until ready.

- [x]    Define Probes: Add liveness and readiness probes to website-deployment.yaml, targeting an endpoint in application that confirms its operational status.
  Again, I searched the soure code direcotry for any endpoint, health, live, ready to find none. So i created status.php file with a configmap and changed the deployment file.
- [x]    Apply Changes: It worked! 
- [x]    Test Probes: Simulate failure scenarios (e.g., manually stopping the application) and observe Kubernetes’ response. 
  It worked! 
- [x]    Outcome: Kubernetes automatically restarts unresponsive pods and delays traffic to newly started pods until they’re ready, enhancing the application’s reliability and availability.

## Step 12: Utilize ConfigMaps and Secrets
Task: Securely manage the database connection string and feature toggles without hardcoding them in the application.
Finally, I can now add my old file that deploy configmap and secrets to avoid hardcoding (I can stop cringing).... 

generate base64 code:
```bash
echo -n "spillYourBeans" | base64
```
To test, lets create a sample database:
```pwsh
kubectl exec pod-hash mariadb -- mariadb -uroot -pspillYourBeans -e "create database if not exists k8s; show databases;"
```
![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/a80ebcca-5b73-4010-af0f-5bfa3d95c91b)

- [x]    Create Secret and ConfigMap: For sensitive data like DB credentials, use a Secret. For non-sensitive data like feature toggles, use a ConfigMap.
  
- [x]    Update Deployment: Reference the Secret and ConfigMap in the deployment to inject these values into the application environment.
- [x]    Outcome: Application configuration is externalized and securely managed, demonstrating best practices in configuration and secret management.

USEFUL COMMANDS:
kubectl exec -it <pod_name> -- /bin/bash
mysql -u <username> -p<password>-uro
SELECT User FROM mysql.user;

mysql -u simplymaria -p

## Step 13: Document Your Process
Create a Git Repository: Create a new repository on your preferred git hosting service (e.g., GitHub, GitLab, Bitbucket).
- [x]    Push Your Code to the Remote Repository
- [x]    Write Documentation: Create a README.md or a blog post detailing each step, decisions made, and how challenges were overcome.

## Extra credit - Package Everything in Helm
Task: Utilize Helm to package your application, making deployment and management on Kubernetes clusters more efficient and scalable.

- [x]    Create Helm Chart: Start by creating a Helm chart for your application. This involves setting up a chart directory with the necessary templates for your Kubernetes resources.
```
helm create retail-therapy-app
```
- [x]    Define Values: Customize your application deployment by defining variables in the values.yaml file. This allows for flexibility and reusability of your Helm chart across different environments or configurations.
- [x]    Package and Deploy: Use Helm commands to package your application into a chart and deploy it to your Kubernetes cluster. Ensure to test your chart to verify that all components are correctly configured and working as expected.
- [x]    Outcome: Your application is now packaged as a Helm chart, simplifying deployment processes and enabling easy versioning and rollback capabilities.

## Extra credit - Implement Persistent Storage
Task: Ensure data persistence for the MariaDB database across pod restarts and redeployments.
- [x]    Create a PVC: Define a PersistentVolumeClaim for MariaDB storage needs.
- [x]    Update MariaDB Deployment: Modify the deployment to use the PVC for storing database data.
- [x]    Outcome: Database data persists beyond the lifecycle of MariaDB pods, ensuring data durability.

## Extra credit - Implement Basic CI/CD Pipeline
Task: Automate the build and deployment process using GitHub Actions.
- []    GitHub Actions Workflow: Create a .github/workflows/deploy.yml file to build the Docker image, push it to Docker Hub, and update the Kubernetes deployment upon push to the main branch.
- []    Outcome: Changes to the application are automatically built and deployed, showcasing an efficient CI/CD pipeline.
