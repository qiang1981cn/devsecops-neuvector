
#! /bin/bash -e


cd $HOME/devsecops/longhorn; sh ./99-one-step-install-longhorn.sh
cd $HOME/devsecops/harbor; sh ./99-one-step-install-harbor.sh
cd $HOME/devsecops/anchore; sh ./99-one-step-install-anchore.sh
cd $HOME/devsecops/sonarqube; sh ./99-one-step-install-sonarqube.sh
#cd $HOME/devsecops/jenkins; sh ./99-one-step-install-jenkins.sh

echo "Here is the Lab info:"
echo
cat my*.sh
cat my*.txt
echo
echo "The first part of script in devsecops VM has been completed. Please continue to setup the GitHub Developer Token."





