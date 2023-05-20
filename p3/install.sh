#!/bin/bash

# Default values
CLUSTER_NAME=$(whoami)
WAIT_TIMEOUT=600s
idx=0

# Function to increment and print a message with the index number
print_msg() {
    idx=$((idx+1))
    echo -e "\033[32m[$idx] $1\033[0m"
}

# Function to check if a command exists and install it if necessary
check_command() {
  for command in "$@"; do
    if ! command -v "$command" &> /dev/null; then
      print_msg "Installing $command"
      case $command in
        docker) install_docker;;
        k3d) install_k3d;;
        kubectl) install_kubectl;;
      esac
    fi
  done
}

install_docker() {
  sudo apt-get remove docker docker-engine docker.io containerd runc
  sudo apt-get -y update
  sudo apt-get -y install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get -y update
  sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_k3d() {
  wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
}

install_kubectl() {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  echo "$(curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256")  kubectl" | sha256sum --check
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl kubectl.sha256
}

# Function to delete the cluster and namespaces
delete_cluster() {
  print_msg "Deleting namespaces"
  sudo kubectl delete namespace argocd dev --ignore-not-found=true
  print_msg "Deleting cluster"
  sudo k3d cluster delete $CLUSTER_NAME
}

# Function to create the cluster and deploy ArgoCD and the app
install_argo() {
  print_msg "Creating cluster"
  sudo k3d cluster create $CLUSTER_NAME --wait --timeout 120s
  print_msg "Creating namespaces"
  sudo kubectl create namespace argocd
  sudo kubectl create namespace dev
  print_msg "Deploying ArgoCD"
  sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  print_msg "Waiting ArgoCD"
  sudo kubectl wait --timeout $WAIT_TIMEOUT --for=condition=Ready pods --all -n argocd
  print_msg "Deploying app"
  sudo kubectl apply -f ./configs.yml
  print_msg "Waiting app"
  sudo kubectl wait --timeout $WAIT_TIMEOUT --for=condition=Ready pods --all -n argocd
  print_msg "Getting admin password"
  PASS=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
  printf "\n\n\tadmin\n\t%s\n" "$PASS"
}

case "$1" in
    "start")
        # Launching the command and storing the process ID in a file
        if [[ $(kubectl get namespace argocd --no-headers --output=custom-columns=NAME:.metadata.name 2>/dev/null) != "argocd" ]]; then
            echo "The 'argocd' namespace does not exist."
            exit 1
        fi
        sudo kubectl port-forward -n argocd svc/argocd-server 8080:443 >/dev/null & echo $! > process_id.txt
        echo "Process launched successfully! ID: $(cat process_id.txt)";;
    "deploy")
        check_command docker kubectl k3d
        delete_cluster
        install_argo
        echo "Deploy done!!\nFor start ArgoCD: install start";;
    "stop")
        # Stopping the process from the ID stored in the file
        if [ -f "process_id.txt" ]; then
            PID=$(cat process_id.txt)
            kill "$PID"
            rm process_id.txt
            echo "Process stopped successfully!"
        else
            echo "No process is currently running."
        fi;;
    *)
        echo "Usage: $0 [deploy|start|stop]"
        exit 1
        ;;
esac
