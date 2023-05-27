#!/bin/bash

# Variables
GITLAB_PRIVATE_TOKEN="glpat-bLMzJ7s84jhj2uFccxts"
USERNAME=$(whoami)
EXTERNAL_IP=$(curl -s ifconfig.me)
EMAIL="42bhamdi@gmail.com"
DOCKER_REGISTRY="https://registry.${USERNAME}-bonus.xip.io/"

# Installer Helm (si ce n'est pas déjà fait)
if ! command -v helm &> /dev/null
then
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  rm get_helm.sh
fi

# Ajouter le repo Helm de GitLab
helm repo add gitlab https://charts.gitlab.io/

# Mettre à jour les repos Helm
helm repo update

# Créer le namespace gitlab si nécessaire
kubectl get namespace gitlab >/dev/null 2>&1 || kubectl create namespace gitlab

# Installer GitLab avec Helm
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --namespace gitlab \
  --set global.hosts.domain=${USERNAME}-bonus.xip.io \
  --set global.hosts.externalIP=$EXTERNAL_IP \
  --set certmanager-issuer.email=$EMAIL \
  --set gitlab-runner.runners.privileged=true

# Ajouter des informations pour permettre au cluster de communiquer avec GitLab
kubectl -n gitlab create secret docker-registry gitlab-registry \
  --docker-server=$DOCKER_REGISTRY \
  --docker-username=root \
  --docker-password=$GITLAB_PRIVATE_TOKEN

# Ajouter un service account pour GitLab dans le namespace 'dev'
kubectl create serviceaccount gitlab --namespace=dev

# Associer le service account 'gitlab' à 'cluster-admin'
kubectl create clusterrolebinding gitlab-admin --clusterrole=cluster-admin --serviceaccount=dev:gitlab
