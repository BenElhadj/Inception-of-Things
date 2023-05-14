#!/bin/bash

ROLE=$1
IP=$2
SERVER_IP=$3

# Installe les dépendances requises sur le nœud.
install_dependencies() {
  # sudo apt-get update && sudo apt-get install -y net-tools
  sudo apt-get update -q
  sudo apt-get upgrade -yq
  sudo apt-get install -yq net-tools vagrant sshpass x11-xkb-utils virtualbox

}

# Affiche un message d'information.
print_info() {
  echo "[INFO] $1"
}

# Installe et configure le serveur k3s.
install_k3s_server() {
  print_info "Installing k3s on server node (ip: $IP)"

  # Définit les options d'exécution pour l'installation de k3s.
  export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $IP --bind-address=$IP --advertise-address=$IP"

  print_info "ARGUMENT PASSED TO INSTALL_K3S_EXEC: $INSTALL_K3S_EXEC"

  # Télécharge et installe k3s.
  curl -sfL https://get.k3s.io | sh -

  # Attend que k3s soit prêt.
  print_info "Doing some sleep to wait for k3s to be ready"
  sleep 10

  # Crée le dossier des scripts s'il n'existe pas.
  sudo mkdir -p /vagrant/scripts/
  sudo chmod -R 777 /vagrant/scripts/

  
  # Copie le token du nœud du serveur vers le répertoire des scripts.
  sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/scripts/

  print_info "Successfully installed k3s on server node"

  # Ajoute un alias pour kubectl.
  echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
}

# Installe et configure l'agent k3s.
install_k3s_agent() {
  print_info "Installing k3s on server worker node (ip: $IP)"

  # Récupère le token du nœud à partir du fichier.
  export TOKEN_FILE="/vagrant/scripts/node-token"
  print_info "Token: $(cat $TOKEN_FILE)"

  # Définit les options d'exécution pour l'installation de l'agent k3s.
  export INSTALL_K3S_EXEC="agent --server https://$SERVER_IP:6443 --token-file $TOKEN_FILE --node-ip=$IP"
  print_info "ARGUMENT PASSED TO INSTALL_K3S_EXEC: $INSTALL_K3S_EXEC"

  # Télécharge et installe l'agent k3s.
  curl -sfL https://get.k3s.io | sh -

  # Ajoute un alias pour kubectl.
  echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
}

# Installe les dépendances sur le nœud.
install_dependencies

# Vérifie le rôle et appelle la fonction appropriée pour installer le serveur ou l'agent k3s.
if [ "$ROLE" == "server" ]; then
  install_k3s_server
elif [ "$ROLE" == "agent" ]; then
  install_k3s_agent
else
  echo "[ERROR] Invalid role specified, must be 'server' or 'agent'"
  exit 1
fi