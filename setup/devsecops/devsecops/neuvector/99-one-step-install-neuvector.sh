#! /bin/bash

# Check if devsecops.cfg file exists
if [ ! -f $HOME/.kube/devsecops.cfg ]; then
  echo "Please copy the kubeconfig file of Rancher devsecops cluster into $HOME/kube/devsecops.cfg file before running this script."
  exit
fi
export KUBECONFIG=$HOME/.kube/devsecops.cfg

NEUVECTOR_IP=`curl -qs http://checkip.amazonaws.com`
NEUVECTOR_FQDN=neuvector.$NEUVECTOR_IP.sslip.io

helm repo add neuvector https://neuvector.github.io/neuvector-helm/
helm repo update

helm install neuvector neuvector/core \
  --namespace cattle-neuvector-system \
  -f ~/devsecops/neuvector/neuvector-values.yaml \
  --set manager.ingress.host=$NEUVECTOR_FQDN \
  --set k3s.enabled=true \
  --version 2.2.3 \
  --create-namespace

echo "Your neuvector is provisioning...."
while [ `kubectl get deploy -n cattle-neuvector-system | grep 1/1 | wc -l` -ne 3 ]
do
  sleep 10
  echo "Wait while neuvector is still provisioning..."
  kubectl get deploy -n cattle-neuvector-system
done


echo
echo "Your neuvector is now successfully provisioned." > $HOME/myneuvector.txt
echo "URL: ${NEUVECTOR_FQDN}" >> $HOME/myneuvector.txt
echo "User: admin" >> $HOME/myneuvector.txt
echo "Password: admin" >> $HOME/myneuvector.txt
cat $HOME/myneuvector.txt

# save the neuvector credential for use at later stage
NEUVECTOR_NODEPORT=$(kubectl get --namespace cattle-neuvector-system -o jsonpath="{.spec.ports[0].nodePort}" services neuvector-svc-controller-api)
echo "export NEUVECTOR_IP=${NEUVECTOR_IP}" > myneuvector.sh
echo "export NEUVECTOR_NODEPORT=${NEUVECTOR_NODEPORT}" >> myneuvector.sh

cp myneuvector.sh ~/
