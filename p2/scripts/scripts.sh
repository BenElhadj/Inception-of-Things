#!/bin/bash
ROLE=$1
IP=$2

install_dependencies() {
  sudo apt-get update
  sudo apt-get upgrade 
  sudo apt-get install -y net-tools
}

print_info() {
  echo "[INFO] $1"
}

install_k3s_server() {
  print_info "Installing k3s on server node (ip: $IP)"
  export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $IP --bind-address=$IP --advertise-address=$IP"
  print_info "ARGUMENT PASSED TO INSTALL_K3S_EXEC: $INSTALL_K3S_EXEC"
  curl -sfL https://get.k3s.io | sh -
  print_info "Sleep to wait for k3s to be ready"
  sleep 10
  print_info "Successfully installed k3s on server node"
  echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
}

deploy_apps() {
  print_info "Deploying apps"
  kubectl apply -f /vagrant/scripts/app1.yml
  kubectl apply -f /vagrant/scripts/app2.yml
  kubectl apply -f /vagrant/scripts/app3.yml
  kubectl apply -f /vagrant/scripts/ingress.yml
  print_info "Apps deployed successfully"
}

install_dependencies

if [ "$ROLE" == "server" ]; then
  install_k3s_server
  deploy_apps
else
  echo "[ERROR] Invalid role specified, must be 'server'"
  exit 1
fi