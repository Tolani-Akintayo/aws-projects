# EKS Deployment for Nest App

This directory contains the Kubernetes manifests and scripts for deploying the Nest app to Amazon EKS, as part of the broader [AWS Projects](../README.md) repository. It focuses on production deployment using Kubernetes on AWS.

## Overview

The Nest app is deployed to EKS for scalable, managed Kubernetes hosting. This setup integrates with AWS services and uses the Docker image built in the [Docker/nest-app](../Docker/nest-app/README.md) directory.

## Files

- **deployment.yaml**: Kubernetes Deployment manifest defining the app pods, replicas, and container specs.
- **service.yaml**: Kubernetes Service to expose the app internally or externally (e.g., LoadBalancer).
- **aws-auth-patch.yaml**: ConfigMap patch for IAM authentication with EKS (allows pods to assume IAM roles).
- **secret-provider-class.yaml**: SecretProviderClass for integrating with AWS Secrets Manager or SSM Parameter Store.
- **eks-deployment.sh**: Bash script to apply the manifests to an EKS cluster.

## Prerequisites

- AWS CLI configured with access to EKS.
- kubectl installed and configured to connect to your EKS cluster.
- Docker image built and pushed (from Docker/nest-app).
- EKS cluster running.

## Setup and Usage

1. **Configure kubectl**:
   Ensure kubectl is pointing to your EKS cluster:
   ```bash
   aws eks update-kubeconfig --region <your-region> --name <cluster-name>
   ```

2. **Deploy to EKS**:
   Run the deployment script:
   ```bash
   ./eks-deployment.sh
   ```
   This applies all YAML files to the cluster.

3. **Verify Deployment**:
   Check pods and services:
   ```bash
   kubectl get pods
   kubectl get services
   ```

4. **Access the App**:
   If using a LoadBalancer, get the external IP:
   ```bash
   kubectl get svc nest-app-service
   ```

## Connection to Overall AWS Projects

This EKS setup deploys the containerized app from [Docker/nest-app](../Docker/nest-app/README.md). It connects to the full AWS ecosystem, including secrets management and IAM. For broader DevOps practices, see the [DevOps Quick Reference](../devops-quick-reference.md) and main [README](../README.md).

## Troubleshooting

- If pods fail, check logs: `kubectl logs <pod-name>`.
- Ensure IAM roles are correctly patched via aws-auth-patch.yaml.
- For secrets issues, verify SecretProviderClass configuration.

## Contributing

Test deployments in a staging cluster. Follow the main repository's guidelines.