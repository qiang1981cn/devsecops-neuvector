#! /bin/bash -e



export KUBECONFIG=$HOME/.kube/devsecops.cfg


# Install harbor with helm chart

echo "Deploying harbor on RKE2 ...."

kubectl create ns harbor
helm repo add harbor https://helm.goharbor.io
helm repo update
helm search repo harbor

export HARBOR_IP=`curl -sq http://checkip.amazonaws.com`
export HARBOR_ADMIN_PWD=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`
export HARBOR_NODEPORT=30443

helm install harbor-registry harbor/harbor --version 1.6.2 \
  -n harbor \
  --set expose.type=nodePort \
  --set expose.nodePort.ports.https.nodePort=${HARBOR_NODEPORT} \
  --set expose.tls.auto.commonName=demo-harbor \
  --set externalURL=https://${HARBOR_IP}:${HARBOR_NODEPORT} \
  --set harborAdminPassword="${HARBOR_ADMIN_PWD}"

# Output should be like this when it's completed.
# ec2-user@ip-172-26-3-222:~> kubectl get po -n harbor
# NAME                                                    READY   STATUS    RESTARTS   AGE
# harbor-registry-harbor-portal-fc7869f46-kt9j2           1/1     Running   0          82s
# harbor-registry-harbor-nginx-b9df69d4f-6x6kd            1/1     Running   0          82s
# harbor-registry-harbor-redis-0                          1/1     Running   0          82s
# harbor-registry-harbor-chartmuseum-db5657f9c-ldrkp      1/1     Running   0          82s
# harbor-registry-harbor-database-0                       1/1     Running   0          82s
# harbor-registry-harbor-notary-server-85b6b59986-4k8dq   1/1     Running   1          82s
# harbor-registry-harbor-notary-signer-7d8bbbb6d4-l28pm   1/1     Running   1          82s
# harbor-registry-harbor-registry-64ddb659db-t7bxm        2/2     Running   0          82s
# harbor-registry-harbor-trivy-0                          1/1     Running   0          82s
# harbor-registry-harbor-core-66bcd59b97-h5t94            1/1     Running   0          82s
# harbor-registry-harbor-jobservice-7fbf95459b-hc2mh      1/1     Running   0          82s

echo "Your Harbor instance is provisioning...."
while [ `kubectl get deploy -n harbor | grep 1/1 | wc -l` -ne 8 ]
do
  sleep 10
  echo "Wait while harbor is still provisioning..."
  kubectl get deploy  -n harbor
done

# save the harbor credential for use at later stage
echo "export HARBOR_URL=${HARBOR_IP}:${HARBOR_NODEPORT}" > myharbor.sh
echo "export HARBOR_USR=admin" >> myharbor.sh
echo "export HARBOR_PWD=${HARBOR_ADMIN_PWD}" >> myharbor.sh

echo "Your harbor instance on RKE2 is up and running!"
echo "URL: https://${HARBOR_IP}:${HARBOR_NODEPORT}" > harbor-credential.txt
echo "User: admin" >> harbor-credential.txt
echo "Password: ${HARBOR_ADMIN_PWD}" >> harbor-credential.txt
echo "Your login credential is saved in a file: harbor-credential.txt"
cat harbor-credential.txt

cp harbor-credential.txt ~/
cp myharbor.sh ~/

echo "Distribute the self-signed harbor certs to cluster devsecops  ..."

sudo ./04-configure-containerd-registry.sh
sudo ./04-configure-docker-client.sh

for vm in rancher cluster1 cluster2; do
  echo
  echo "Distribute the self-signed harbor certs to cluster $vm ..."
  scp myharbor.sh $vm:~
  scp 04-configure-containerd-registry.sh $vm:~/configure-containerd-node.sh
done


for i in $(seq 1 12); do
  sleep 10
  echo "$i :wait for the RKE2 restarting with the Harbor certs and harbor recovering...."
done

while [ `kubectl get deploy -n harbor | grep 1/1 | wc -l` -ne 8 ]
do
  sleep 10
  echo "Wait while harbor is still recovering .."
  kubectl get deploy  -n harbor
done


#! /bin/bash

pwd
ls
source myharbor.sh


echo "Login to harbor with docker client ..."
sudo docker login $HARBOR_URL -u $HARBOR_USR -p $HARBOR_PWD

#! /bin/bash -e

echo "Download docker images for sample application build..."

source myharbor.sh

sudo docker pull maven:3-jdk-8-slim
sudo docker tag maven:3-jdk-8-slim $HARBOR_URL/library/java/maven:3-jdk-8-slim
sudo docker push $HARBOR_URL/library/java/maven:3-jdk-8-slim

sudo docker pull susesamples/sles15sp3-openjdk:11.0-3.56.1
sudo docker tag susesamples/sles15sp3-openjdk:11.0-3.56.1 $HARBOR_URL/library/suse/sles15sp3-openjdk:11.0-3.56.1
sudo docker push $HARBOR_URL/library/suse/sles15sp3-openjdk:11.0-3.56.1

echo
echo
echo ============================================================
echo "Congrats! Your Harbor instance has been setup successfully."
cat harbor-credential.txt
echo


