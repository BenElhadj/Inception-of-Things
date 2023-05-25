#!/bin/bash

# Variables
utilisateur="$USER"

# Mettre à jour le système
sudo apt -y update

# Installer les dépendances
sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common xclip

# Installation de Docker
function installer_docker {
    if ! command -v docker &> /dev/null
    then
        echo "========================================================"
        echo "================ Installation de Docker ================"
        echo "========================================================"

        # Importer la clé GPG de Docker
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --yes --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg

        # Ajouter le dépôt Docker à Debian
        echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Installer Docker
        sudo apt -y update
        sudo apt -y install docker-ce docker-ce-cli containerd.io

        # Démarrer le service
        sudo systemctl enable --now docker

        # Ajouter l'utilisateur au groupe Docker s'il n'en fait pas déjà partie
        if ! id -nG "$utilisateur" | grep -qw docker; then
            sudo usermod -aG docker $utilisateur
        fi
    fi
}

# Installation de kubectl
function installer_kubectl {
    if ! command -v kubectl &> /dev/null
    then
        echo "========================================================"
        echo "================ Installation de kubectl ==============="
        echo "========================================================"

        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
        echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm -f kubectl
    fi
}

# Installation de k3d
function installer_k3d {
    if ! command -v k3d &> /dev/null
    then
        echo "========================================================"
        echo "================== Installation de k3d ================="
        echo "========================================================"

        curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
        echo "source <(k3d completion bash)" >> ~/.bashrc
        sudo k3d cluster create mycluster
        sudo kubectl create namespace dev
        sudo kubectl create namespace argocd
        sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
        curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
        
        sudo chown $USER:$USER ~/.kube/config
        chmod +x argocd
    fi
}

# Configuration du contrôleur d'Ingress Traefik
function configurer_Ingress_Traefik {
    echo "========================================================"
    echo "===== Configuration du contrôleur d'Ingress Traefik ===="
    echo "========================================================"

    # Installation de Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh

    # Ajouter le repo de Traefik Helm
    helm repo add traefik https://helm.traefik.io/traefik

    # Créer une namespace pour Traefik
    sudo kubectl create namespace traefik

    # Installer Traefik avec Helm
    helm install traefik traefik/traefik --namespace traefik
}

function installer_argocd {
    echo "========================================================"
    echo "================= Installation d'Argocd ================"
    echo "========================================================"

    sudo kubectl apply -f ./deployment.yml

    local counter=0
    local prev_ready_pods=0
    local ready_pods
    while [ "$prev_ready_pods" -lt 7 ]
    do
        sleep 1
        counter=$((counter+1))
        local hours=$((counter / 3600))
        local minutes=$(((counter / 60) % 60))
        local seconds=$((counter % 60))
        ready_pods="$(sudo kubectl get pod -n argocd 2>/dev/null | grep "1/1" | wc -l)"
        if [ "$ready_pods" -gt "$prev_ready_pods" ]; then
            echo -e "\rPod(s) prêt(s) : $ready_pods/7 après $(printf "%02d:%02d:%02d" $hours $minutes $seconds) ..."
            prev_ready_pods=$ready_pods
        else
            echo -ne "\rVeuillez patienter, l'installation d'Argocd est en cours... $(printf "%02d:%02d:%02d" $hours $minutes $seconds) ..."
        fi
    done
    echo -e "\nLe cluster est prêt après $(printf "%02d:%02d:%02d" $hours $minutes $seconds) !"
}

# Interface utilisateur d'ArgoCD
function interface_utilisateur_argocd {
    echo "========================================================"
    echo "===== Démarrage de l'interface utilisateur d'ArgoCD ===="
    echo "========================================================"

    while true
    do sudo kubectl port-forward -n argocd svc/argocd-server 8080:443 1>/dev/null 2>/dev/null
    done &
    while true
    do sudo kubectl port-forward -n dev svc/wil-playground 8888:8888 1>/dev/null 2>/dev/null
    done &
}

# Récupération des informations d'identification ArgoCD
function recuperer_identifiants {
    echo "========================================================"
    echo "========= Récupération d'identification ArgoCD ========="
    echo "========================================================"
    echo "============= Informations d'identification ============"
    echo "========================================================"

    echo "Lien vers ArgoCD : https://localhost:8080"
    echo "Nom d'utilisateur : admin"
    echo -n "Mot de passe : "
    sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	echo ""
}

installer_docker
installer_kubectl
installer_k3d
configurer_Ingress_Traefik
installer_argocd
interface_utilisateur_argocd
recuperer_identifiants

echo "Toutes les installations sont terminées avec succès!"
