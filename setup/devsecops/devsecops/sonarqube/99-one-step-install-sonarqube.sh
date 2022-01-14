#! /bin/bash

# Check if devsecops.cfg file exists
if [ ! -f $HOME/.kube/devsecops.cfg ]; then
  echo "Please copy the kubeconfig file of Rancher devsecops cluster into $HOME/kube/devsecops.cfg file before running this script."
  exit
fi
export KUBECONFIG=$HOME/.kube/devsecops.cfg


# check if the longhorn has been installed
if [ `kubectl get sc | grep default | wc -l` -ne 1 ]; then
  echo "Please deploy longhorn on devsecops cluster before running this script."
  exit
fi

# check if git is installed
git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?
if [ $GIT_IS_AVAILABLE -ne 0 ]; then
  sudo zypper install -y git-core
fi

set -e

git clone https://github.com/SonarSource/helm-chart-sonarqube.git --depth 1 -b sonarqube-lts-1.0.19
cd helm-chart-sonarqube/charts/sonarqube
helm dependency update
kubectl create namespace sonarqube

# kubectl taint nodes devsecops sonarqube=true:NoSchedule --overwrite=true
kubectl label node devsecops  sonarqube=true --overwrite=true

helm install -f ~/devsecops/sonarqube/sonarqube-values.yaml -n sonarqube sonarqube ./

echo "Your Sonarqube instance is provisioning...."
while [ `kubectl get sts -n sonarqube | grep 1/1 | wc -l` -ne 2 ]
do
  sleep 10
  echo "Wait while sonarqube is still provisioning..."
  kubectl get sts -n sonarqube
done

export NODE_IP=`cat $HOME/mylab_vm_list.txt | grep suse0908-devsecops | cut -d '|' -f 4 | xargs`
export NODE_PORT=$(kubectl get --namespace sonarqube -o jsonpath="{.spec.ports[0].nodePort}" services sonarqube-sonarqube)

echo
echo "Your Sonarqube instance is ready ..." > ~/mysonarqube.txt
echo http://$NODE_IP:$NODE_PORT/login >> ~/mysonarqube.txt
echo username: admin >> ~/mysonarqube.txt
echo initial password: admin >> ~/mysonarqube.txt
echo



cat ~/mysonarqube.txt


echo "Added steps to automate the setting of Jenkins"

export SONARQUBE_USR=admin
export SONARQUBE_INITIAL_PWD=admin
export SONARQUBE_PWD=admin123

echo updated password: $SONARQUBE_PWD >> ~/mysonarqube.txt


export SONARQUBE_URL=$(echo "http://$NODE_IP:$NODE_PORT")
export URL_ChangePWD=$(echo "'$SONARQUBE_URL/api/users/change_password?login=$SONARQUBE_USR&password=$SONARQUBE_PWD&previousPassword=$SONARQUBE_INITIAL_PWD'")
export URL_NewToken=$(echo "$SONARQUBE_URL/api/user_tokens/generate?name=spring-petclinic")
export URL_NewProject=$(echo "'$SONARQUBE_URL/api/projects/create?project=spring-petclinic&name=spring-petclinic'")

echo "Automatic setting of Sonarqube"

echo "Change the initial password $SONARQUBE_INITIAL_PWD into $SONARQUBE_PWD"
echo "curl -X POST -u $SONARQUBE_USR:$SONARQUBE_INITIAL_PWD $URL_ChangePWD"
echo "curl -X POST -u $SONARQUBE_USR:$SONARQUBE_INITIAL_PWD $URL_ChangePWD" | sh

echo "Request a Sonarqube token"

echo "curl -X POST -u $SONARQUBE_USR:$SONARQUBE_PWD $URL_NewToken"
echo "curl -X POST -u $SONARQUBE_USR:$SONARQUBE_PWD $URL_NewToken" | sh > tokenresponse.txt


echo "export SONARQUBE_URL=$NODE_IP:$NODE_PORT" > ~/mysonarqube.sh
echo "export SONARQUBE_SECRET=$(cat tokenresponse.txt | cut -f 3 -d ',' | cut -f 4 -d '"')" >> ~/mysonarqube.sh

echo "Create a new project in Sonarqube"

echo "curl -X POST -u $SONARQUBE_USR:$SONARQUBE_PWD $URL_NewProject"
echo "curl -X POST -u $SONARQUBE_USR:$SONARQUBE_PWD $URL_NewProject" | sh


echo "The updated sonarqube access info: "


