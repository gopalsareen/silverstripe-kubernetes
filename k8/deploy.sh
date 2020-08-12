#!/bin/bash

# build image name
DOCKER_USERNAME={DOCKER_HUB_USERNAME}
IMAGE_NAME={IMAGE_NAME}
TAG=$(date +%s)
IMAGE=$DOCKER_USERNAME/$IMAGE_NAME:$TAG

# build and push image to docker registry
docker build -t $IMAGE .
docker push $IMAGE

# apply image to php deployment
sed  "s|{{image}}|$IMAGE|g" ./config/php_deployment.yaml | kubectl apply -f  -

