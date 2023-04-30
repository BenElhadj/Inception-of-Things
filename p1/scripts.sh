#!/bin/bash

ROLE=$1

sudo apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
sudo snap install kubectl --classic

if [ "$ROLE" == "master" ]; then
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --node-ip 192.168.56.110" sh -s - server

  sudo mkdir -p /home/vagrant/.kube
  sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
  sudo chown -R vagrant:vagrant /home/vagrant/.kube

elif [ "$ROLE" == "worker" ]; then
  sudo apt-get install -yq jq

  # Wait for master to become available
  until curl -sSL http://192.168.56.110:8080/node-token > /dev/null 2>&1; do
    echo "Waiting for master to become available..."
    sleep 5
  done

  K3S_TOKEN=$(curl -sSL http://192.168.56.110:8080/node-token)
  curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$K3S_TOKEN INSTALL_K3S_EXEC="--node-ip 192.168.56.111" sh -s - agent
fi
