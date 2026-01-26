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
 

## Projects

This repository includes four main AWS projects, each with diagrams illustrating the architecture:

1. **Hosting a Static Website on AWS Using the 3-Tier Architecture**: Demonstrates deploying a static site with web, app, and data tiers. [View Diagram](Images/1.Hosting%20a%20Static%20Website%20on%20AWS%20Using%20the%203-Tier%20Architecture%20.png)

2. **Hosting a Dynamic Web Application on AWS Using the 3-Tier Architecture**: Shows a dynamic app setup with scalable tiers. [View Diagram](Images/2.Hosting%20a%20Dynamic%20Web%20Application%20on%20AWS%20Using%20the%203-Tier%20Architecture%20.png)

3. **Hosting a Dynamic Web Application on AWS with Docker and ECS**: Covers containerization and deployment using ECS. [View Diagram](Images/3.Hosting%20a%20Dynamic%20Web%20Application%20on%20AWS%20with%20Docker%20and%20ECS.png)

4. **Hosting a Dynamic Web Application on AWS with Docker and EKS**: Focuses on Kubernetes deployment with EKS, including the Nest app example. [View Diagram](Images/4.Hosting%20a%20Dynamic%20Web%20Application%20on%20AWS%20with%20Docker%20and%20EKS.png)

The Docker/nest-app and eks/nest-app directories provide practical implementation for project 4.

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
