#!/bin/bash

# ================================================================
# Define Docker build arguments and image push variables
# ================================================================

# Define build arguments
PROJECT_NAME="nest"
ENVIRONMENT="dev"
RECORD_NAME="www"
DOMAIN_NAME="tolani-akintayo.com"
GITHUB_USERNAME="Tolani-Akintayo"
REPOSITORY_NAME="nest-app-code"
SERVICE_PROVIDER_FILE_NAME="AppServiceProvider"
APPLICATION_CODE_FILE_NAME="nest"
RDS_ENDPOINT="dev-nest-db.cu2idoemakwo.us-east-1.rds.amazonaws.com"
RDS_DB_NAME="applicationdb"
RDS_DB_USERNAME="admin"
IMAGE_NAME="nest"
IMAGE_TAG="latest"
SECRET_NAME="test"
AWS_REGION="us-east-2"

# Define Docker image push variables
ECR_REPO_NAME="nest"
LOCAL_IMAGE_NAME="nest"
IMAGE_TAG="latest"
AWS_REGION="us-east-2"
AWS_ACCOUNT_ID="65163246143"

# ================================================================
# Retrieve secrets from AWS Secrets Manager
# ================================================================

# Retrieve secret from Secrets Manager
echo -e "\033[36mRetrieving secrets from AWS Secrets Manager...\033[0m"
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

if [ $? -ne 0 ]; then
    echo -e "\033[31mError: Failed to retrieve secret from AWS Secrets Manager\033[0m" >&2
    exit 1
fi
echo -e "\033[32mSecrets retrieved successfully!\033[0m"

# Parse JSON and retrieve the values of personal_access_token and password from the secret
PERSONAL_ACCESS_TOKEN=$(echo "$SECRET_JSON" | jq -r '.personal_access_token')
RDS_DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

# Enable BuildKit
export DOCKER_BUILDKIT=1

# Set secrets as environment variables for BuildKit (will be mounted as secrets in the container)
export PERSONAL_ACCESS_TOKEN_SECRET="$PERSONAL_ACCESS_TOKEN"
export RDS_DB_PASSWORD_SECRET="$RDS_DB_PASSWORD"

# ================================================================
# Build the Docker image
# ================================================================

# Build the Docker image with build arguments
echo -e "\033[36mBuilding Docker image...\033[0m"
docker build \
    --secret id=personal_access_token,env=PERSONAL_ACCESS_TOKEN_SECRET \
    --secret id=rds_db_password,env=RDS_DB_PASSWORD_SECRET \
    --build-arg PROJECT_NAME="$PROJECT_NAME" \
    --build-arg ENVIRONMENT="$ENVIRONMENT" \
    --build-arg RECORD_NAME="$RECORD_NAME" \
    --build-arg DOMAIN_NAME="$DOMAIN_NAME" \
    --build-arg GITHUB_USERNAME="$GITHUB_USERNAME" \
    --build-arg REPOSITORY_NAME="$REPOSITORY_NAME" \
    --build-arg SERVICE_PROVIDER_FILE_NAME="$SERVICE_PROVIDER_FILE_NAME" \
    --build-arg APPLICATION_CODE_FILE_NAME="$APPLICATION_CODE_FILE_NAME" \
    --build-arg RDS_ENDPOINT="$RDS_ENDPOINT" \
    --build-arg RDS_DB_NAME="$RDS_DB_NAME" \
    --build-arg RDS_DB_USERNAME="$RDS_DB_USERNAME" \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    .

if [ $? -ne 0 ]; then
    echo -e "\033[31mError: Docker build failed\033[0m" >&2
    exit 1
fi
echo -e "\033[32mDocker image built successfully!\033[0m"

# Clean up temporary environment variables
unset PERSONAL_ACCESS_TOKEN_SECRET
unset RDS_DB_PASSWORD_SECRET
echo -e "\033[32mTemporary environment variables cleaned up.\033[0m"

# ================================================================
# Push the image to AWS ECR
# ================================================================

# Check if repository exists, create if it doesn't
echo -e "\033[36mChecking if ECR repository exists...\033[0m"
if aws ecr describe-repositories \
    --repository-names "$ECR_REPO_NAME" \
    --region "$AWS_REGION" > /dev/null 2>&1; then
    echo -e "\033[32mRepository already exists. Skipping creation.\033[0m"
else
    echo -e "\033[36mCreating repository...\033[0m"
    aws ecr create-repository \
        --repository-name "$ECR_REPO_NAME" \
        --region "$AWS_REGION"

    if [ $? -ne 0 ]; then
        echo -e "\033[31mError: Failed to create ECR repository\033[0m" >&2
        exit 1
    fi
    echo -e "\033[32mRepository created successfully!\033[0m"
fi

# Tag the image
echo -e "\033[36mTagging Docker image for ECR...\033[0m"
docker tag "${LOCAL_IMAGE_NAME}:${IMAGE_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"

if [ $? -ne 0 ]; then
    echo -e "\033[31mError: Docker tag failed\033[0m" >&2
    exit 1
fi
echo -e "\033[32mDocker image tagged successfully!\033[0m"

# Authenticate Docker to ECR
echo -e "\033[36mAuthenticating Docker to ECR...\033[0m"
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

if [ $? -ne 0 ]; then
    echo -e "\033[31mError: Docker login to ECR failed\033[0m" >&2
    exit 1
fi
echo -e "\033[32mDocker authenticated to ECR successfully!\033[0m"

# Push the image to ECR
echo -e "\033[36mPushing Docker image to ECR...\033[0m"
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"

if [ $? -ne 0 ]; then
    echo -e "\033[31mError: Docker push to ECR failed\033[0m" >&2
    exit 1
fi
echo -e "\033[32mDocker image pushed to ECR successfully!\033[0m"

# Print an empty line for better readability
echo ""

# Final success message
echo -e "\033[32m========================================\033[0m"
echo -e "\033[32mAll operations completed successfully!\033[0m"
echo -e "\033[32m========================================\033[0m"
