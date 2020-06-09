#!/bin/bash


# secrets
echo "----Creating secrets"
kubectl apply -f ./config/secrets.yaml

# volumes
echo "----Creating Persistent volumes and claims"
kubectl apply -f ./config/nfs_pv.yaml
kubectl apply -f ./config/nfs_pvc.yaml


# database
echo "----Deploying Database"
kubectl apply -f ./config/db_deployment.yaml

# nginx service
echo "----Deploying nginx service"
kubectl apply -f ./config/nginx_deployment.yaml


# php service
echo "----Deploying php service"
./deploy.sh