# DevOps Quick Reference Guide

## AWS Configuration

### Initial Setup
```bash
# Configure AWS credentials
aws configure
```

## GitHub SSH Setup

### Generate SSH Key Pairs
```bash
# Generate ED25519 key pair
ssh-keygen -t ed25519
```

---

## Git Operations

### Repository Setup
```bash
# Clone repository from GitHub
git clone https://github.com/username/repository-name.git

# Navigate into repository
cd repository-name
```

### Basic Git Workflow
```bash
# Check repository status
git status

# Stage all changes
git add .

# Commit changes
git commit -m "Committing all files"

# Push to remote repository
git push origin main
```

### Git Large File Storage (LFS)
For files larger than 100MB:
```bash
# Install Git LFS (one-time setup per machine)
git lfs install

# Track large files by extension
git lfs track "*.zip"

# Add the .gitattributes file
git add .gitattributes

# Add large file
git add nest.zip

# Commit and push
git commit -m "Add large ZIP file using Git LFS"
git push
```

---

## Docker Management

### System Cleanup
```bash
# Remove all images and volumes from your computer
docker system prune -a --volumes -f
```

### Building Docker Images
```bash
# Build your Docker image
docker build -t <IMAGE_NAME>:<IMAGE_TAG> .

# Example:
docker build -t nest:latest .

# View the Docker image after building it
docker image ls
```

### Pushing Docker Images to Amazon ECR

**Step 1: Create an ECR Repository**
```bash
aws ecr create-repository --repository-name <REPOSITORY_NAME> --region <AWS_REGION>

# Example:
aws ecr create-repository --repository-name nest --region us-east-1
```

**Step 2: Tag the Image**
```bash
docker tag <IMAGE_NAME>:<IMAGE_TAG> <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<REPOSITORY_NAME>:<IMAGE_TAG>

# Example:
docker tag nest:latest 651783246143.dkr.ecr.us-east-1.amazonaws.com/nest:latest

# View the Docker image after tagging it
docker image ls
```

**Step 3: Authenticate Docker to ECR**
```bash
aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com

# Example:
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 651783246143.dkr.ecr.us-east-1.amazonaws.com
```

**Step 4: Push the Image to ECR**
```bash
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<REPOSITORY_NAME>:<IMAGE_TAG>

# Example:
docker push 651783246143.dkr.ecr.us-east-1.amazonaws.com/nest:latest
```

---

## Script Permissions

### Windows (PowerShell)
```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Unblock script files
Unblock-File -Path .\build-image.ps1
Unblock-File -Path .\push-image.ps1
```

### Mac/Linux (Bash)
```bash
# Make scripts executable
chmod +x build-image.sh
chmod +x push-image.sh
```

#### Fixing Line Ending Issues
If you encounter "bad interpreter" errors with scripts created on Windows:
```bash
# Fix line endings with dos2unix
dos2unix push-image.sh
```

If you don't have `dos2unix` installed:
```bash
# Install via Homebrew
brew install dos2unix
```

Alternative fix without installing dos2unix:
```bash
# Use sed to remove carriage returns
sed -i '' 's/\r$//' push-image.sh
```

After fixing line endings, make the script executable:
```bash
chmod +x push-image.sh
```

---

## AWS EKS Operations

### Cluster Connection
```bash
# Update kubeconfig to connect to EKS cluster
aws eks update-kubeconfig --name <CLUSTER_NAME> --region <AWS_REGION>

# Example:
aws eks update-kubeconfig --name dev-eks-cluster --region us-east-1

# Verify connection
kubectl cluster-info

# View current context
kubectl config current-context

# List all available contexts
kubectl config get-contexts
```

### Namespace Operations
```bash
# List all namespaces
kubectl get namespaces

# Create a namespace
kubectl create namespace <NAMESPACE_NAME>

# Delete a namespace (deletes all resources within it)
kubectl delete namespace <NAMESPACE_NAME>

# Example:
kubectl delete namespace dev-nest-eks-namespace
```

### Pod Operations
```bash
# List all pods in a namespace
kubectl get pods -n <NAMESPACE>

# Example:
kubectl get pods -n dev-nest-eks-namespace

# List pods with more details (node, IP, etc.)
kubectl get pods -n <NAMESPACE> -o wide

# Watch pods in real-time
kubectl get pods -n <NAMESPACE> -w

# Describe a pod (detailed info, events, errors)
kubectl describe pod <POD_NAME> -n <NAMESPACE>

# View pod logs
kubectl logs <POD_NAME> -n <NAMESPACE>

# View logs with follow (real-time)
kubectl logs -f <POD_NAME> -n <NAMESPACE>

# View logs for a specific container in multi-container pod
kubectl logs <POD_NAME> -c <CONTAINER_NAME> -n <NAMESPACE>

# View previous container logs (after crash)
kubectl logs <POD_NAME> -n <NAMESPACE> --previous
```

### SSH into Pod
```bash
# Get the pod name first
kubectl get pods -n <NAMESPACE>

# Exec into the pod with bash
kubectl exec -it <POD_NAME> -n <NAMESPACE> -- /bin/bash

# Exec into the pod with sh (if bash not available)
kubectl exec -it <POD_NAME> -n <NAMESPACE> -- /bin/sh

# Example:
kubectl exec -it dev-nest-eks-deployment-7d4cc757c-8nf2q -n dev-nest-eks-namespace -- /bin/bash
```

### Deployment Operations
```bash
# List all deployments
kubectl get deployments -n <NAMESPACE>

# Describe a deployment
kubectl describe deployment <DEPLOYMENT_NAME> -n <NAMESPACE>

# Force deployment to pull new image and restart pods
kubectl rollout restart deployment <DEPLOYMENT_NAME> -n <NAMESPACE>

# Example:
kubectl rollout restart deployment dev-nest-eks-deployment -n dev-nest-eks-namespace

# Check rollout status
kubectl rollout status deployment <DEPLOYMENT_NAME> -n <NAMESPACE>

# View rollout history
kubectl rollout history deployment <DEPLOYMENT_NAME> -n <NAMESPACE>

# Rollback to previous version
kubectl rollout undo deployment <DEPLOYMENT_NAME> -n <NAMESPACE>

# Scale deployment
kubectl scale deployment <DEPLOYMENT_NAME> --replicas=<COUNT> -n <NAMESPACE>
```

### Service Operations
```bash
# List all services
kubectl get services -n <NAMESPACE>

# List services with external IPs
kubectl get svc -n <NAMESPACE>

# Describe a service
kubectl describe service <SERVICE_NAME> -n <NAMESPACE>
```

### ConfigMaps and Secrets
```bash
# List ConfigMaps
kubectl get configmaps -n <NAMESPACE>

# List Secrets
kubectl get secrets -n <NAMESPACE>

# View ConfigMap content
kubectl describe configmap <CONFIGMAP_NAME> -n <NAMESPACE>

# View Secret content (base64 encoded)
kubectl get secret <SECRET_NAME> -n <NAMESPACE> -o yaml
```

### Resource Management
```bash
# Apply a manifest file
kubectl apply -f <FILENAME>.yaml

# Delete resources from a manifest file
kubectl delete -f <FILENAME>.yaml

# Get all resources in a namespace
kubectl get all -n <NAMESPACE>

# Delete a specific pod (will be recreated by deployment)
kubectl delete pod <POD_NAME> -n <NAMESPACE>
```

### Debugging Commands
```bash
# Get events in a namespace (useful for troubleshooting)
kubectl get events -n <NAMESPACE> --sort-by='.lastTimestamp'

# Check resource usage (requires metrics-server)
kubectl top pods -n <NAMESPACE>
kubectl top nodes

# Port forward to a pod for local testing
kubectl port-forward <POD_NAME> <LOCAL_PORT>:<POD_PORT> -n <NAMESPACE>

# Example: Forward local port 8080 to pod port 80
kubectl port-forward dev-nest-eks-deployment-7d4cc757c-8nf2q 8080:80 -n dev-nest-eks-namespace
```

---

## AWS ECS Operations

### Prerequisites

#### IAM Permissions
Ensure the ECS task role has these policies:
- `AmazonSSMFullAccess`
- `AmazonECSTaskExecutionRolePolicy`

#### Session Manager Plugin

**macOS:**
```bash
brew install session-manager-plugin
session-manager-plugin --version
```

**Windows:**
Download and install from:
```
https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe
```

### SSH into ECS Container

**Step 1: Enable Execute Command**
```bash
# PowerShell
aws ecs update-service `
    --cluster dev-ecs-cluster `
    --service nest-service `
    --enable-execute-command `
    --force-new-deployment

# Bash
aws ecs update-service \
    --cluster dev-ecs-cluster \
    --service nest-service \
    --enable-execute-command \
    --force-new-deployment
```

**Step 2: Check Service Status**
```bash
# PowerShell
aws ecs describe-services `
    --cluster dev-ecs-cluster `
    --services nest-service

# Bash
aws ecs describe-services \
    --cluster dev-ecs-cluster \
    --services nest-service
```

**Step 3: Get Task ARN**
```powershell
# PowerShell
$taskArn = (aws ecs list-tasks --cluster dev-ecs-cluster --service-name nest-service --query 'taskArns[0]' --output text)
```
```bash
# Bash
taskArn=$(aws ecs list-tasks --cluster dev-ecs-cluster --service-name nest-service --query 'taskArns[0]' --output text)
```

**Step 4: Execute Command**
```bash
# PowerShell
aws ecs execute-command `
    --cluster dev-ecs-cluster `
    --task $taskArn `
    --container nest `
    --interactive `
    --command "/bin/sh"

# Bash
aws ecs execute-command \
    --cluster dev-ecs-cluster \
    --task $taskArn \
    --container nest \
    --interactive \
    --command "/bin/sh"
```

---

## EC2 Connections

### Connect via EC2 Instance Connect Endpoint
```bash
aws ec2-instance-connect ssh --instance-id <instance-id>
```

---

## Notes

- Always ensure proper IAM permissions before executing ECS commands
- Git LFS is required for files exceeding GitHub's 100MB limit
- Session Manager plugin is required for ECS container access
- Use `docker system prune` carefully as it removes all unused containers, images, and volumes
- For EKS, ensure `kubectl` is installed and configured with `aws eks update-kubeconfig`
- Use `-n <namespace>` flag consistently to avoid operating on the wrong namespace