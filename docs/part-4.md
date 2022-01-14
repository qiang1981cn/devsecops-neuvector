# Part 4 - Integrating Jenkins pipeline with Rancher


In this part, we will see how easy it is to create workload environment and apply the Continous Delivery for your application by using Rancher.

We will do steps as below:

1. Create two workload RKE2 Clusters `Cluster1` and `Cluster2` by Rancher.
2. Group them into one workload cluster group.
3. Create the CD pipeline for GitHub repository `spring-petclinic-helmchart`, and setup the deployment dest as workload cluster group.

You can observe that Rancher will automatically deploy the Helm Chart from GitHub into `Cluster1` and `Cluster2`. 

## 1. Create worklad clusters by Rancher

### 1.1 Create Cluster1

a) Navigate to Rancher Cluster Management UI, click `Create`

![Rancher UI](./Images-10-13-2021/part1-step5-1-create-custom-all-in-1-rke2-cluster-pg1.png)

You will be presented with `Cluster:Create` form. To create a new cluster, choose `Custom`to provision cluster using RKE2/K3s on existing node.

![Rancher UI](./Images-10-13-2021/part1-step5-2-rancher-ui-create-cluster-custom-all-in-1-rke2-cluster-pg2.png)

In `ClusterName` type `cluster1`
Under `Cluster Configuration` `Basics` form leave everthing as default. 

![Rancher UI](./Images-10-13-2021/part1-step5-3-rancher-ui-create-cluster-custom-all-in-1-rke2-cluster-pg3.png)

In `Labels & Annotation` tab, under `Labels`, provide the key:vaue pair. In `Key` type `env` and  `Value` type `dev` and hit `Create`

![Rancher UI](./Images-10-13-2021/part1-step5-4-rancher-ui-create-cluster-custom-all-in-1-rke2-cluster-pg4.png)

You will be presented with `Registration` tab. Check the box 'Insecure: Select this to skip TLS...' and click on the command to copy. 

![Rancher UI](./Images-10-13-2021/part1-step5-5-rancher-ui-create-cluster-custom-all-in-1-rke2-cluster-copy-command-pg5.png)


b) Ensure you are on your local workstation/machine Terminal and inside your git repo cloned.

```
cd ~/workshop
```
and run the below script. 

```
./setup-rke-cluster1.sh
```
The Terminal will be seeking input command to create the cluster. 
Paste the registration command from Rancher side and press enter to start the cluster build process. 

![Rancher UI](./Images-10-13-2021/part1-step5-6-cluster1-terminal-copy-n-paste-create-cluster1-command-pg6.png)

![Rancher UI](./Images-10-13-2021/part1-step5-7-cluster1-terminal-copy-n-paste-create-cluster1-command-pg7.png)


### 1.2 Create Cluster2

The process is the same with `Cluster1`, just make sure:

- In Rancher GUI:
1. give the cluster name is `Cluster2`
2. remember to provide the same label as `Key` is `env` and  `Value` is `dev`.

- In your local workstation/machine Terminal:
1. run script setup-rke-cluster2.sh and paste the registration command of `Cluster2`.
```
./setup-rke-cluster2.sh
```

Finally we should see both clusters `cluster1` and `cluster2` visible in Rancher UI, and wait till their status change to Active.



## 2. Configure Rancher Continous Delivery (CD)


### 2.1 Create a Cluster Group

With Rancher Continous Delivery (CD), one can manage individual or group of clusters. Managing cluster via Group reduces adminstrative efforts.

1) Rancher UI > `Global Apps` > `Continuous Delivery` > `Cluster Group` and click on `Create`. Give it a name `development`

Here we are going to use the same Label which was used to create `Cluster1` and `Cluster2`.

2) Under Cluster Selector provide the following values
Key:`env`
Operator: `in list`
Value:`dev` 
 
Once you key in the key:value pair, Rancher will use the selector labels to indentify the clusters to be associated with our newly created cluster group in Rancher Continuous Delivery. You will see it show 2 cluster been selected. 

![Rancher-Continous Delivery (CD)](./Images-10-13-2021/part4-Fleet-Cluster-Group-creation-pg1.png)

3) Click on `Create` which will create our first Cluster Group.

![Rancher-Continous Delivery (CD)](./Images-10-13-2021/part4-Fleet-Cluster-Group-creation-success-pg2.png)


### 2.2 Configure GitHub Repo spring-petclinic-helmchart 

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
d) Use the dropdown option and select the Cluster Group we created previosuly `development`. 
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

In Rancher UI, on either `Cluster1` or `Cluster2` you should see our Spring PetClinic Container running. Take a closer look at the version, it should say `spring-petclinic:v1.0.x`.

![Rancher UI](./Images-10-13-2021/part4-Fleet-Cluster-Group-PetClinic-depoloyment-service-link-ready.png)

Now let try to open the Application in a new Browser window
Rancher UI > Cluster Exlporer > Cluster1 > `Services` Tab to expose the Container Application.

![Rancher UI](./Images-10-13-2021/part4-Fleet-Cluster-Group-PetClinic-App-working.png)

Check our applivation version  `spring-petclinic:v1.0.x` as indicated in previous step.

Your PetClinic App is been successfully depoyed.

With this, let's put everything together and proceed to [Part 5 Put Everything Together](part-5.md)

