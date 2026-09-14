# Information

# Walkthrough

First you should use 'docker-compose up' to set up the containers.
Then in another CLI window (if you use Docker on Windows with Ubuntu installed in WSL, open with 'wsl -d Ubuntu') and paste 'kind create cluster --name mycluster',
then 'kind get kubeconfig --name mycluster > kubeconfig.yaml', then 'kind get kubeconfig --name mycluster --internal > kubeconfig-internal.yaml'.
This makes deployment of the app possible with k8+helm.
