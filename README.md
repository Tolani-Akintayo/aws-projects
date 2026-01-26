# AWS Projects

This repository contains various AWS-related projects, focusing on deploying a Nest app using Docker and Kubernetes on EKS. It demonstrates a full CI/CD pipeline from containerization to cloud deployment.

## Project Structure

- **devops-quick-reference.md**: Quick reference guide for DevOps practices, tools, and commands used in AWS deployments.
- **Docker/nest-app**: Docker configuration for the Nest app.
  - Dockerfile: Builds the app image.
  - build-push-image.sh: Script to build and push the image.
  - start-services.sh: Starts local services.
  - db-migrate-script.sh: Runs database migrations.
  - AppServiceProvider.php: Laravel service provider.
  - README.md: Detailed setup for Docker.
- **eks/nest-app**: EKS deployment manifests for the Nest app.
  - deployment.yaml: Kubernetes Deployment.
  - service.yaml: Kubernetes Service.
  - aws-auth-patch.yaml: IAM auth patch.
  - secret-provider-class.yaml: Secrets management.
  - eks-deployment.sh: Deployment script.
  - README.md: Detailed EKS setup.
- **Images/**: Directory containing project diagrams.
  - [PROJECT 1 - Hosting a Static Website on AWS Using the 3-Tier Architecture](Images/PROJECT 1 - Hosting a Static Website on AWS Using the 3-Tier Architecture .png): Diagram for static website hosting.
  - [PROJECT 2 - Hosting a Dynamic Web Application on AWS Using the 3-Tier Architecture](Images/PROJECT 2 - Hosting a Dynamic Web Application on AWS Using the 3-Tier Architecture .png): Diagram for dynamic web app hosting.
  - [PROJECT 3 - Hosting a Dynamic Web Application on AWS with Docker and ECS](Images/PROJECT 3 - Hosting a Dynamic Web Application on AWS with Docker and ECS.png): Diagram for Docker and ECS deployment.
  - [PROJECT 4 - Hosting a Dynamic Web Application on AWS with Docker and EKS](Images/PROJECT 4 - Hosting a Dynamic Web Application on AWS with Docker and EKS.png): Diagram for Docker and EKS deployment.

## Overview

The Nest app (a PHP/Laravel application) is containerized using Docker and deployed to AWS EKS for production. The Docker setup in `Docker/nest-app` builds the image, while `eks/nest-app` handles Kubernetes deployment.

## Prerequisites

- AWS account with EKS access.
- Docker and kubectl installed.
- AWS CLI configured.

## Setup and Usage

1. **Local Development**:
   - Navigate to `Docker/nest-app`.
   - Build and run locally: `./build-push-image.sh` then `./start-services.sh`.
   - Run migrations: `./db-migrate-script.sh`.

2. **Production Deployment**:
   - Push image to ECR.
   - Go to `eks/nest-app`.
   - Deploy: `./eks-deployment.sh`.
   - Access via LoadBalancer.

For detailed steps, see the READMEs in `Docker/nest-app` and `eks/nest-app`.

## Contributing

- Test changes locally.
- Follow DevOps best practices from `devops-quick-reference.md`.
- Use Git for version control.
