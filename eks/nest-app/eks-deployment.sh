#!/bin/bash

# ================================================================
# Define variables
# ================================================================

# Cluster variables
REGION="us-east-1"
CLUSTER_NAME="rentzone-cluster"
AWS_ACCOUNT_ID="651783246143"

# Namespace
NAMESPACE="rentzone"

# Service account variables
SERVICE_ACCOUNT_NAME="rentzone-service-account"
SECRET_MANAGER_ACCESS_POLICY_NAME="rentzone-secret-access-policy"

# Manifest file names
AUTH_CONFIG_FILE_NAME="aws-auth-patch.yaml"
SECRET_PROVIDER_CLASS_FILE_NAME="secret-provider-class.yaml"
DEPLOYMENT_FILE_NAME="deployment.yaml"
SERVICE_FILE_NAME="service.yaml"

# ================================================================
# Verify required tools are installed
# ================================================================

# Verify kubectl is installed
kubectl version --client

# Verify eksctl is installed
eksctl version

# Verify Helm is installed
helm version

# ================================================================
# Configure kubectl to connect to EKS cluster
# ================================================================

# Update kubeconfig to connect to EKS cluster
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

# List all available contexts in kubeconfig
kubectl config get-contexts

# Set the current context to the EKS cluster
kubectl config use-context "arn:aws:eks:${REGION}:${AWS_ACCOUNT_ID}:cluster/${CLUSTER_NAME}"

# ================================================================
# Create and configure namespace
# ================================================================

# Create a namespace
kubectl create namespace $NAMESPACE

# Set namespace for all subsequent kubectl commands
kubectl config set-context --current --namespace=$NAMESPACE

# Verify the namespace
kubectl config view --minify | grep 'namespace:'

# ================================================================
# Install Secrets Store CSI Driver
# ================================================================

# Add the Secrets Store CSI Driver Helm repository
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts

# Update Helm repositories
helm repo update

# Install the Secrets Store CSI Driver
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system

# Verify that Secrets Store CSI Driver has started
kubectl --namespace=kube-system get pods -l "app=secrets-store-csi-driver"

# Install AWS provider for Secrets Store CSI Driver
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

# ================================================================
# Associate IAM OIDC provider with EKS cluster
# ================================================================

# Associate IAM OIDC provider (run only once per cluster)
eksctl utils associate-iam-oidc-provider --region=$REGION --cluster=$CLUSTER_NAME --approve

# ================================================================
# Create IAM service account for Secrets Manager access
# ================================================================

# Create IAM service account with Secrets Manager access policy
eksctl create iamserviceaccount \
    --name $SERVICE_ACCOUNT_NAME \
    --namespace $NAMESPACE \
    --region $REGION \
    --cluster $CLUSTER_NAME \
    --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${SECRET_MANAGER_ACCESS_POLICY_NAME}" \
    --approve \
    --override-existing-serviceaccounts

# ================================================================
# Apply Kubernetes manifests
# ================================================================

# Apply aws-auth patch configuration
kubectl apply -f $AUTH_CONFIG_FILE_NAME

# Apply secret provider class configuration
kubectl apply -f $SECRET_PROVIDER_CLASS_FILE_NAME

# Apply deployment configuration
kubectl apply -f $DEPLOYMENT_FILE_NAME

# Apply service configuration
kubectl apply -f $SERVICE_FILE_NAME

# Verify deployments
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE