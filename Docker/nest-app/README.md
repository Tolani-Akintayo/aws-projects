# Docker Setup for Nest App

This directory contains the Docker configuration for the Nest app, which is part of the broader [AWS Projects](../README.md) repository. It focuses on containerizing the application for local development and deployment.

## Overview

The Nest app is a web application (built with PHP/Laravel) that can be run in a Docker container. This setup allows for easy environment consistency and integration with AWS services like EKS for production deployment.

## Files

- **Dockerfile**: Defines the Docker image for the Nest app, including base image, dependencies, and build steps.
- **build-push-image.sh**: Bash script to build the Docker image and push it to a registry (e.g., ECR for AWS).
- **start-services.sh**: Script to start the necessary services, such as the app container and database.
- **db-migrate-script.sh**: Script to run database migrations for the app.
- **AppServiceProvider.php**: PHP service provider file for Laravel, handling app services and bootstrapping.

## Prerequisites

- Docker installed on your machine.
- Access to an AWS account (for pushing images to ECR).
- Basic knowledge of Docker commands.

## Setup and Usage

1. **Build the Image**:
   Run the build script to create the Docker image:
   ```bash
   ./build-push-image.sh
   ```
   This will build the image and push it to your configured registry.

2. **Start Services**:
   Use the start script to launch the app and dependencies:
   ```bash
   ./start-services.sh
   ```
   This may start a web server, database, etc.

3. **Run Migrations**:
   After starting services, run database migrations:
   ```bash
   ./db-migrate-script.sh
   ```

4. **Access the App**:
   Once running, access the app at `http://localhost:3000` (adjust port as needed).

## Connection to Overall AWS Projects

This Docker setup is designed to work seamlessly with the EKS deployment in the [eks/nest-app](../eks/nest-app/README.md) directory. The Docker image built here can be deployed to Kubernetes on AWS EKS for production. Ensure the image is pushed to ECR and referenced in the EKS YAML files (e.g., `deployment.yaml`).

For more details on the full AWS deployment pipeline, see the main [README](../README.md) and [DevOps Quick Reference](../devops-quick-reference.md).

## Troubleshooting

- If builds fail, check Docker logs and ensure all dependencies are installed.
- For EKS issues, verify IAM roles and network configurations in the eks directory.

## Contributing

Follow the guidelines in the main repository. Test changes locally with Docker before pushing.