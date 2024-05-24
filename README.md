# Adapting a CentOS-based Kubernetes Resume Challenge to Windows using PowerShell

Introduction:

This is a sample e-commerce application initially built to be deployed on CentOS systems. My goal was to adapt this application for deployment on a Windows environment using PowerShell and a sprinkle of [Terraform](terraform). The point of doing it was to demonstrate how Kubernetes deployment works across systems.

Join the challenge [here](https://cloudresumechallenge.dev/docs/extensions/kubernetes-challenge/)!

![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/725911e1-743d-4431-93ba-3cffba923956)

## Key Skills and Technologies
- Kubernetes: Cluster creation, deployment, scaling, rolling updates, autoscaling.
- Docker: Containerizing applications, creating Dockerfiles, pushing images to Docker Hub.
- PowerShell: Automating tasks, managing Azure resources.
- Azure: Creating and managing resources using CLI and Terraform.
- CI/CD: Setting up GitHub Actions workflows.
- Configuration Management: Using ConfigMaps and Secrets in Kubernetes.

## Challenge infrastructure
- [Sample e-commerce website code](https://github.com/kodekloudhub/learning-app-ecommerce) by KodeKloud.
- [Dockerfile configuration](Dockerfile) that uses [slightly updated source code](abundant-source-no-banner). 
- [Kubernetes Manifests](challenge-steps) configured following the challenge instructions.
- Command Line assistants for Azure, Kubectl, Docker, Helm.

## Challenge Optonal Extra Credits: 
- [Helm chart](helm) configuration.
- [Persistent Storage for the Database](persistent-storage)
- [CI/CD Pipeline](github) using secrets and zero output login commands. 

## Centos to Windows Conversion requirements
- WSL to run Docker Engine
- Attention to CRLF and LF
- and a bucketfull of sheer willpower... 

## Note on Azure authentication on GitHub 
Using Azure CLI can accidentally reveal subscriptionID during the pipeline run as credential are printed out as JSON output. The login commands can be modified to prevent such accidental secrets disclosure. 

# Step by Step Process 
  
## Step 1: Certification
KodeKloud offers the [Certified Kubernetes Application Developer (CKAD) course](https://kodekloud.com/courses/certified-kubernetes-application-developer-ckad/) to equip developers with the knowledge and skills needed to tackle this challenge effectively. 
I am very keen to get a Kubernetes certification, as soon as I finished preparing for the [Terraform Associate exam](https://github.com/ZCHAnalytics/terraform-associate-prep)! Watch this space.... 

## Step 2: Containerise E-Commerce Website and Database
- [x] Create a Dockerfile with php-apache base image, mysqli extension, and the application source code.
- [x] Update database connection strings to point to a Kubernetes service named mysql-service.
- [x] Build and Push the Docker Image
- [x] Database Containerization

First, I copied the source code to the project directory (as an archive, without cloning the repository itself):
  ```pwsh
  & { mkdir abundant_source ; cd abundant_source ; curl -sL <link>/archive/master.tar.gz | tar -xzf - --strip-components=1 } | Out-Null
  ```
Second, I used the provided arguments in mysqli function to correctly define database variables in Kubernetes manifests. This way, the apache container can interpolate the values from the cluster environment to retrieve products info from the database in a separate container.

When building and pushing this [Docker image](Dockerfile), I opened a WSL terminal so that Docker Engine can run. As soon as the images are pushed to Docker Hub, I close the Docker Engine to avoid clogging my RAM. 

## Step 3. Set up Kubernetes on a Public Cloud Provider
- [x] Cluster creation
- [ ] 
In this [file](azure-commands.md) you can see the relevant commands for creating a cluster on Azure and deleted it after the challenge is completed. At a later stage, I used [Terraform](terraform) to deploy the Azure Infrastructure.

![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/eb0e0efa-63c7-45bc-83c3-5566d0615575)

## Step 4: Deploy E-commerce Website to Kubernetes
- [x] 4.1. Kubernetes deployment 
The initial deployment uses hardcorded variables but this will change after Step 12. 
To test, lets enter the container and run some commands, for instance in database container:

![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/a80ebcca-5b73-4010-af0f-5bfa3d95c91b)

## Step 5: Expose Your Website [v]
- [x] Service creation with Load Balancer
We could choose to do this step via CLI command or a yaml file. 
Via CLI:
`kubectl expose deploy/<deployment name> --port 80 --target-port 80 --type LoadBalancer --name=<external service name>`

![image](https://github.com/ZCHAnalytics/kubernetes-challenge/assets/146954022/93e1fd2b-9230-4e50-b3a6-6143d1f7f478)

With a [service manifest](5-service-apache.yaml)

## Step 6: Implement Configuration Management by add a feature toggle
- [x] Create a ConfigMap with the data FEATURE_DARK_MODE=true
- [x] Update Deployment to include the environment variable from the ConfigMap
- [x] Then we need to add a 'simple feature toggle' in the application code (e.g., an environment variable FEATURE_DARK_MODE that enables a CSS dark theme). 

It turns out it was not 'simple' at all. The source code had either missing dependencies (probably due to five years passed since it first creation) or the relevant css and php snippets were deliberately left out to make the Challenge even more challenging. 

This was my first time using php and css style. I created very simple [dark-mode.css](dark-mode.css) file just to demonstrate how dynamic toggles can me introduced and managed.

If I set the toggle to false and re-apply configmap and deploy again, the website reverts to default light background. 

## Step 7: Scale Web Application to prepare for a marketing campaign expected to triple traffic.
- [x] Evaluate Current Load with `kubectl get pods` to assess the current number of running pods
- [x] Increase replicas in deployment or use `kubectl scale deployment/<name> --replicas=6` to handle the increased load
- [x] Observe the deployment scaling up with `kubectl get pods`

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/8213670e-9e45-45bb-81ed-4b4b75b768e5)

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/b74cdbc1-f1a9-4412-8795-93f30ba9e78f)

## Step 8: Perform a Rolling Update to include a new promotional banner for the marketing campaign.
- [x]    Modify the web application’s code to include the promotional banner
- [x]    Build and Push New Image
- [x]    Rolling Update: Update deployment with the new image version and apply the changes
- [x]    Use `kubectl rollout status deployment/<name>` to watch the rolling update process.

Again, as in Step 6, there was not code for a promotional banner, so I added a zany snipper about trips to the Moon, with yellow background. 

![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/67bc7793-10ee-46b7-b845-0600c4122734)

## Step 9: Roll back to the previous version.
- [x] Identify Issue: After deployment, monitoring tools indicate a problem affecting user experience (namely the zany yellow promotional banner).
- [x] Execute `kubectl rollout undo deployment/<name>` to revert to the previous deployment state.
- [x] Verify Rollback: Ensure the website returns to its pre-update state (without the promotional banner).

My promotional banner snippet was just a demonstration of how rolling update and rollbacks work, not for real-life scenarios. So was good to remove it (as moon inhabitants complained about the traffic). 

## Step 10: Autoscale the Application based on CPU usage to handle unpredictable traffic spikes.
- [x]  Create a Horizontal Pod Autoscaler targeting 50% CPU utilization, with a minimum of 2 and a maximum of 10 pods.
- [x]  Simulate Load: Use a tool like Apache Bench to generate traffic and increase CPU load.
- [x]  Monitor Autoscaling: Observe the HPA in action with `kubectl get hpa`.

This can be done thoruhg a [file](challenge-steps/10-autoscale.yaml) or with a CLI command:
kubectl autoscale deployment a-pod-for-retail-therapy --cpu-percent=50 --min=2 --max=10
ab -n 100 -c 10 URL

Before:
![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/96861b3c-d5cd-4663-8eb3-eaabbd0af441)

After:
![image](https://github.com/ZCHAnalytics/k8s-resume-challenge/assets/146954022/02fc18a4-1f97-4c15-8a05-7eed9eb8ddf6)

## Step 11: Implement Liveness and Readiness Probes to ensure the web application is restarted if it becomes unresponsive and doesn’t receive traffic until ready.
- [x]    Add liveness and readiness probes, targeting an endpoint in application that confirms its operational status.
- [x]    Simulate failure scenarios (e.g., manually stopping the application) and observe Kubernetes’ response. 

Again, I searched the soure code for any endpoint and found none and so had to create an additional php file.

## Step 12: Utilize ConfigMaps and Secrets
- [x]    Use secrets for sensitive data like DB credentials
- [x]    Reference the Secrets in the deployment to inject these values into the application environment.

Finally, secrets! Kubernetes needs password to be converted into a binary string. I used a free base64 converter on the web.

## Step 13: Document Process in GitHub
- [x]    Push Code to the Remote Repository.
- [x]    Create a README.md or a blog post detailing each step, decisions made, and how challenges were overcome. 

## Extra credit - Package Everything in Helm
- [x] Create Helm Chart 
- [x] Customize the deployment by defining variables in the values.yaml file.
- [x] Use Helm commands to package the application into a chart and deploy to to your Kubernetes cluster.
```helm
helm create retail-therapy-app
helm install retail-therapy-app ./helm
helm upgrade retail-therapy-app ./helm/app-with-banner
```
![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/e6e0db7c-b145-4e18-ba38-814d12f86830)

![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/98b44929-53d2-45df-a221-da7f53020849)

![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/60e102cc-7c27-4633-bd3a-68643fd0dc6b)

## Extra credit - Implement Persistent Storage for the MariaDB database across pod restarts and redeployments.
- [x] Define a PersistentVolumeClaim for MariaDB storage needs.
- [x] Modify the deployment to use the PVC for storing database data.

## Extra credit - Implement Basic CI/CD Pipeline
- [x] GitHub Actions Workflow.

I needed to create a Service Principal for the resource group, then configure Docker and Azure credentials as Github secrets.
Service Principal: 
`az ad sp create-for-rbac --name "github-actions" --role contributor --scopes /subscriptions/<your subscription ID>/resourceGroups/<your resource group name>`

Hide Azure subscription ID from printing out in the GitHUb Actions by adding > /dev/null to the azure login command, like this:
`az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID > /dev/null`

![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/29d71b2d-f7a1-4af1-9239-46e364e77ec0)

## Project Directory 
🌍  Project Directory Tree
├───.github
|       └───workflows/deploy.yml
├───abundant-source-no-banner
│       ├───css/dark-mode.css # new file for dark-mode 
|       └───index.php # with added dark mode toggle
├───challenge-steps/
├───helm
│   ├───app-with-banner/
│   ├───charts/
│   |   ├───apache/
│   |   └───mariadb/
|   ├───templates
|   |   └───secrets.yaml
│   └───Chart.yaml
├───persistent-storage
├───terraform
│   └───main.tf
|───troubleshooting/
└───Dockerfile
