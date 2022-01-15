
#! /bin/bash -e

echo
echo "Make sure two sample application docker images have been uploaded to harbor"
echo

source ./myharbor.sh

echo "Login to harbor with docker client ..."
sudo docker login $HARBOR_URL -u $HARBOR_USR -p $HARBOR_PWD

echo "Download docker images for sample application build..."

sudo docker pull maven:3-jdk-8-slim
sudo docker tag maven:3-jdk-8-slim $HARBOR_URL/library/java/maven:3-jdk-8-slim
sudo docker push $HARBOR_URL/library/java/maven:3-jdk-8-slim

sudo docker pull susesamples/sles15sp3-openjdk:11.0-3.56.1
sudo docker tag susesamples/sles15sp3-openjdk:11.0-3.56.1 $HARBOR_URL/library/suse/sles15sp3-openjdk:11.0-3.56.1
sudo docker push $HARBOR_URL/library/suse/sles15sp3-openjdk:11.0-3.56.1


echo
echo "Automate the Jenkins config file and install Jenkins."
echo

cd $HOME/devsecops/jenkins; sh ./99-one-step-install-jenkins.sh





