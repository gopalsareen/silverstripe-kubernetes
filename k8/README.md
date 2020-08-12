# Deploy SilverStripe on Kubernetes - PHP + NGINX + MYSQL


Simplified setup to deploy SilverStripe application on Kubernetes cluster.
It builds the baked docker image from the latest version of 
[SilverStripe Recipe Cms](https://github.com/silverstripe/recipe-cms) and ship it to the Docker registry.



### Requirements

----
 - [Kubernetes](https://kubernetes.io/)  - [Multi-Node cluster](https://github.com/gopalsareen/kubernetes-php-app)
 - [Docker](https://www.docker.com/)


### Stack

----
 - Php
 - Nginx
 - Mysql
 

 
### How to install 

#### Setup docker registry access

1) Login to docker hub with username and password:
 
    ```docker login```

    It will generate a file that holds the authentication token

    ```cat ~/.docker/config.json```
 
    Output is similar to:

          {
              "auths": {
                  "https://index.docker.io/v1/": {
                      "auth": "*******"
                  }
              }
          }
          
2) Create a secret

        kubectl create secret generic dock-reg-cred     --from-file=.dockerconfigjson=</path/to/.docker/config.json>    --type=kubernetes.io/dockerconfigjson

 **Note:** this will create a secret named **dock-reg-cred** which can be consumed by any pod in the cluster securely.



#### Run the install file [install.sh](install.sh)
 
 Break down of install file
 
 ----
 
 Following will create and deploy the secrets, volumes and service.
 
 **Secrets yaml holds the credentials in base64-encoded format which required to boot-up the mysql service. And if you are using any other sensitive data, I strongly recommend storing it using the [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/).
 ```yaml
 kubectl apply -f ./config/secrets.yaml
 ```
 
 ```yaml
 kubectl apply -f ./config/nfs_pv.yaml
 kubectl apply -f ./config/nfs_pvc.yaml
 
 kubectl apply -f ./config/db_deployment.yaml

 kubectl apply -f ./config/nginx_deployment.yaml
   ```
 
 Below will build a docker image from the scratch installed with SilverStripe [SilverStripe Recipe Cms](https://github.com/silverstripe/recipe-cms)
 and deploy the **PHP** service based on the image.
 
   [deploy.sh](deploy.sh)
    
    
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
    





#### Modify the `Dockerfile` to install your own version of SilverStripe recipe and app/themes modules.

    # Clone silverstripe recipe
    RUN mkdir /bin/build-code/ && git clone https://github.com/silverstripe/recipe-cms.git /bin/build-code/
    
    # Composer install the silvrstripe application
    RUN composer install -d /bin/build-code/ \
        --ignore-platform-reqs \
        --no-interaction \
        --prefer-dist \
        --verbose


Deployment will expose the application on one of the node ip: http://IP:32380




### License
 
 - [LICENSE](LICENSE)


## WIN!
