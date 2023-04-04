#!/bin/bash

# Enable the shell option to immediately exit if any command fails
set -e

# Download and set the Kops binary to executable
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x ./kops
sudo mv -f ./kops /usr/local/bin/

# Download and set the Kubectl binary to executable
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv -f ./kubectl /usr/local/bin/kubectl

# Set environment variables for the AWS region and S3 bucket name
export REGION="eu-central-1"
export STATE_BUCKET="proxy-cluster-kops-state-store"

# Create the S3 bucket using awscli
#aws s3api create-bucket \
#  --bucket "${STATE_BUCKET}" \
#  --region "${REGION}" \
#  --create-bucket-configuration LocationConstraint="${REGION}"

# Set environment variables for the Kops cluster name and state store
export NAME="proxycluster.k8s.local" 
export KOPS_STATE_STORE="s3://${STATE_BUCKET}"

# Generate an SSH key for Kops to use for instance access
sudo ssh-keygen -b 2048 -t rsa -f ${HOME}/.ssh/id_rsa -q -N ""

# Create the Kops cluster with the desired specifications
kops create cluster \
    --name ${NAME} \
    --state ${KOPS_STATE_STORE} \
    --node-count 2 \
    --master-count 1 \
    --zones eu-central-1a,eu-central-1b \
    --master-zones eu-central-1a \
    --node-size t2.medium \
    --master-size t2.medium \
    --master-volume-size 20 \
    --node-volume-size 20 \
    --networking flannel \
    --cloud-labels "group=proxy"

# Update the Kops cluster with administrative access
kops update cluster ${NAME} --yes --admin
    
# Edit the Kops cluster if necessary
#kops edit cluster ${NAME}

# Wait for the Kops cluster to validate before proceeding
kops validate cluster --wait 10m

# Delete the Kops cluster if desired
#kops delete cluster --name $NAME --yes
