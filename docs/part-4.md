# Part 4 - Integrating Jenkins pipeline with Rancher


In this part, we will see how easy it is to create workload environment and apply the Continous Delivery for your application by using Rancher.

We will do steps as below:

1. Create the CD pipeline for GitHub repository `spring-petclinic-helmchart`.

You can observe that Rancher will automatically deploy the Helm Chart from GitHub into cluster`devsecops`. 


## 1. Configure Rancher Continous Delivery (CD)


### 1.1 Configure GitHub Repo spring-petclinic-helmchart 

Before we ahead for configuring the Git Repo, we need to Git Repository URL.

Follow the instruction below to get to Git Repository URL.

1) Login into GitHub account
2) Search for the repository named `spring-petclinic-helmchart` 
3) Click on the Repository URL and you will be taken into the `code` tab. In the code tab, you will be in the `main` branch.
4)  Click on `code` tab, use the drop down menu and you will be presented with the repositroy url. 
5) Click on the clipboard icon to copy the URL from `HTTPS` tab. 

Sample below for reference. 

![Rancher UI](./Images-10-13-2021/part4-configure-git-repo-forked-url.png)

6) In Rancher UI > `Global Apps` > `Continous Delivery` > `Git Repos` click on `Create`
a) Give a name to your Git Rep `Name`
b) Paste the Git Repo URL in `Repository URL`  
c) In the Branche Name type `main` 
d) Use the dropdown option and select the Cluster we created previosuly `devsecops`. 
e) Provide a Namespace `spring-petclinic`

Sample output of the GitRepo configuration below

![Rancher UI](./Images-10-13-2021/part4-Fleet-Git-Repo-Create-pg.png)

You have successfully completed Rancher Contious Delivery configuration. 

Since the pipeline is still in progress, you can expect below output 

![Rancher UI](./Images-10-13-2021/part4-Fleet-Git-repo-status-Not-Ready-gp1.png)

![Rancher UI](./Images-10-13-2021/part4-Fleet-Git-repo-status-Not-Ready-gp2.png)


## 3. View Jenkins Pipeline Progess and Rancher Continous Delivery in action.

As your jenkins pipeline is getting built, you can expect different progress/view. 

Below are sample screenshot for your reference only. 

For easy viewing, split the screen (Horizontal or Vertical) as per your preference to observe the jenkins pipeline progress. 

### Jenkins approval stage.

At one stage in the pipeline, you will be prompted to `Appove` the code changes. Options available will be `Yes` or `No`. 

![Job Status in Jenkins and Rancher UI's ](./Images-10-13-2021/part3-pet-clinic-pipeline-approval-pg6.png)

Upon approval, jenkins commits the changes to Git Repo. The container image will be stored in your Harbor Registry.

You can toggle Harbor UI > Library > Repoistory where you will see our application container image available.

![Job Status in Jenkins and Rancher UI's ](./Images-10-13-2021/part4-Harbor-UI-PetClinic-Container-Image-pg1.png)

### Rancher Continous Delivery in Action

Rancher Continous Delivery is configured for a `Git Repo` and a branch in our case `main` branch to watch for changes/commits. Rancher Continuous CD will pick up the changes and deploy the changes  to the target cluster group

![Job Status in Jenkins and Rancher UI's ](./Images-10-13-2021/part4-pet-clinic-git-repo-update-in-progress-pg1.png)

![Rancher UI](./Images-10-13-2021/part4-Fleet-Git-repo-status-Not-Ready-gp1.png)

![Rancher UI](./Images-10-13-2021/part4-Fleet-Git-repo-status-Ready-gp1.png)

In Rancher UI, on `devsecops` you should see our Spring PetClinic Container running. Take a closer look at the version, it should say `spring-petclinic:v1.0.x`.

![Rancher UI](./Images-10-13-2021/part4-Fleet-Cluster-Group-PetClinic-depoloyment-service-link-ready.png)

Now let try to open the Application in a new Browser window
Rancher UI > Cluster Exlporer > devsecops > `Services` Tab to expose the Container Application.

![Rancher UI](./Images-10-13-2021/part4-Fleet-Cluster-Group-PetClinic-App-working.png)

Check our applivation version  `spring-petclinic:v1.0.x` as indicated in previous step.

Your PetClinic App is been successfully depoyed.

With this, let's put everything together and proceed to [Part 5 Put Everything Together](part-5.md)

