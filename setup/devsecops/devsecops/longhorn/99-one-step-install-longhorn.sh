#! /bin/bash -e


mkdir -p ~/.kube
sudo cp /etc/rancher/rke2/rke2.yaml ~/.kube/devsecops.cfg
sudo chmod 666 ~/.kube/devsecops.cfg


# Install Kubernetes tools
echo "Installing Kubernetes Client Tools - kubectl and helm ..."

curl -sLS https://dl.get-arkade.dev | sh
sudo mv arkade /usr/local/bin/arkade
sudo ln -sf /usr/local/bin/arkade /usr/local/bin/ark

ark get helm
sudo mv /home/ec2-user/.arkade/bin/helm /usr/local/bin/

ark get kubectl
sudo mv /home/ec2-user/.arkade/bin/kubectl /usr/local/bin/


export KUBECONFIG=$HOME/.kube/devsecops.cfg
kubectl get node
helm ls -A

echo "Your Kubectl and helm is ready!"


helm repo add longhorn https://charts.longhorn.io
helm repo update

helm install longhorn longhorn/longhorn \
  --set persistence.defaultClassReplicaCount=2 \
  --version 1.2.2 \
  --namespace longhorn-system \
  --create-namespace

echo "Your Longhorn is provisioning...."
while [ `kubectl -n longhorn-system get deploy | grep longhorn- | grep 1/1 | wc -l` -ne 2 ]
do
  sleep 10
  echo "Wait while longhorn is still provisioning..."
  kubectl get deploy -n longhorn-system
done

echo "Your Longhorn CSI is provisioning...."
while [ `kubectl -n longhorn-system get deploy | grep csi- | grep 3/3 | wc -l` -ne 4 ]
do
  sleep 10
  echo "Wait while longhorn CSI is still provisioning..."
  kubectl get deploy -n longhorn-system
done

echo 
echo "Your longhorn is ready..."
echo


