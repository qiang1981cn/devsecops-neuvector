# Build Your Own DevSecOps using SUSE Rancher 2.6

![SUSE Rancher - DevSecOps Scenario](./docs/overview.png)


This repository contains all the scripts and Kubernetes manifests for complimenting its hands-on workshop.

* [Part 1 - Initial Lab Setup on AWS Lightsail](./docs/part-1.md)
* [Part 2 - Configure GitHub & Jenkins](./docs/part-2.md)
* [Part 3 - Configure Jenkins Pipeline to deploy spring-petclinic App](./docs/part-3.md)
* [Part 4 - Rancher Continuous Delivery](./docs/part-4.md)
* [Part 5 - Put it all together](./docs/part-5.md)
* [Part 6 - Lab Clean Up](./docs/part-6.md)


# Background

This repo is the short version of SUSE DevSecOps Workshop:
https://github.com/dsohk/rancher-devsecops-workshop

The purpose of short version is to simplify the setup procedure and make it easier to deliver as a external activity such as a customer demo. 

Compare to the original version, the change can be summarized:

- Shrink the lab size:
From 7 VM to 4 VM, and from 5 Clusters to 4 Clusters. 
The layout of lab scenario is updated accordingly and shown in the picture in the top.
Specifically, removed the standalone cluster for Harbor and placed Harbor into the devsecops cluster.
- Automate the manual config steps in Jenkins for:
Add credentials for GitHub and SonarQube.
Add the Env Setting for Harbor.
Add the Plugin settings for SonarQube.
- Remove the steps to manually download the cluster config file of devsecops into Harbor VM. It’s automated into part of devsecops VM setting.
- Combine the installation steps of Longhorn, Harbor, SonarQube, Anchore and Jenkins.  

There are still some steps which have not been further scripted due to different considerations:

- It's infeasible to automate the Rancher UI operation for creating/importing RKE2 Cluster.
Till Rancher 2.6.3, creating/importing RKE cluster via Rancher API/CLI is not supported.
- It's infeasible to script the Jenkins setting for plugin Anchore.
Anchore setting is bound to use web GUI and cannot be automated by script or code.
- As workshop perpose including explaining the CICD process, the GitHub website operation (fork a project, setup token, edit the code) remain as GUI operation for presentation at demo.
- The Jenkins job (Pipeline) operation (create / trigger build) is possible to script by Jenkins API.
It remains as GUI operation for presentation at demo.


# References

* [Rancher Documentation](https://rancher.com/docs/)
* [Longhorn](https://longhorn.io/docs/1.1.1/)
* [Jenkins on Kubernetes](https://www.jenkins.io/doc/book/installing/kubernetes/)
* [Harbor Helm Chart](https://github.com/goharbor/harbor-helm)
* [Anchore Helm Chart](https://github.com/anchore/anchore-charts)
* [Deploy SonarQube on Kubernetes](https://docs.sonarqube.org/latest/setup/sonarqube-on-kubernetes/)

# Feedback

If you have any comments, suggestions or feedback to help improving this workshop, please feel free to reach out to our Team.

## Stay connected with
- Github Issues
- SUSE Community Group

