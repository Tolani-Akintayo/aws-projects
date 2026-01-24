# ================================================================
# Define Docker build arguments and image push variables
# ================================================================

# Define build arguments
$PROJECT_NAME = "nest"
$ENVIRONMENT = "dev"
$RECORD_NAME = "www"
$DOMAIN_NAME = "dev-nest-clb-1207998692.us-east-2.elb.amazonaws.com"
$GITHUB_USERNAME = "Tolani-Akintayo"
$REPOSITORY_NAME = "nest-app-code"
$SERVICE_PROVIDER_FILE_NAME = "AppServiceProvider"
$APPLICATION_CODE_FILE_NAME = "nest"
$RDS_ENDPOINT = "dev-nest-db.cpackc2kqv7w.us-east-2.rds.amazonaws.com"
$RDS_DB_NAME = "applicationdb"
$RDS_DB_USERNAME = "admin"
$IMAGE_NAME = "nest"
$IMAGE_TAG = "latest"
$SECRET_NAME = "dev-app-secrets"
$AWS_REGION = "us-east-2"

# Define Docker image push variables
$ECR_REPO_NAME = "nest"
$LOCAL_IMAGE_NAME = "nest"  
$IMAGE_TAG = "latest"
$AWS_REGION = "us-east-2"
$AWS_ACCOUNT_ID = "285750004830"

# ================================================================
# Retrieve secrets from AWS Secrets Manager
# ================================================================

# Retrieve secret from Secrets Manager
Write-Host "Retrieving secrets from AWS Secrets Manager..." -ForegroundColor Cyan
$SECRET_JSON = aws secretsmanager get-secret-value `
    --secret-id $SECRET_NAME `
    --region $AWS_REGION `
    --query SecretString `
    --output text

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to retrieve secret from AWS Secrets Manager"
    exit 1
}
Write-Host "Secrets retrieved successfully!" -ForegroundColor Green

# Parse JSON and retrieve the values of personal_access_token and password from the secret
$SECRET = $SECRET_JSON | ConvertFrom-Json
$PERSONAL_ACCESS_TOKEN = $SECRET.personal_access_token
$RDS_DB_PASSWORD = $SECRET.password

# Enable BuildKit
$env:DOCKER_BUILDKIT = 1

# Set secrets as environment variables for BuildKit (will be mounted as secrets in the container)
$env:PERSONAL_ACCESS_TOKEN_SECRET = $PERSONAL_ACCESS_TOKEN
$env:RDS_DB_PASSWORD_SECRET = $RDS_DB_PASSWORD

# ================================================================
# Build the Docker image
# ================================================================

# Build the Docker image with build arguments
Write-Host "Building Docker image..." -ForegroundColor Cyan
docker build `
    --secret id=personal_access_token,env=PERSONAL_ACCESS_TOKEN_SECRET `
    --secret id=rds_db_password,env=RDS_DB_PASSWORD_SECRET `
    --build-arg PROJECT_NAME="$PROJECT_NAME" `
    --build-arg ENVIRONMENT="$ENVIRONMENT" `
    --build-arg RECORD_NAME="$RECORD_NAME" `
    --build-arg DOMAIN_NAME="$DOMAIN_NAME" `
    --build-arg GITHUB_USERNAME="$GITHUB_USERNAME" `
    --build-arg REPOSITORY_NAME="$REPOSITORY_NAME" `
    --build-arg SERVICE_PROVIDER_FILE_NAME="$SERVICE_PROVIDER_FILE_NAME" `
    --build-arg APPLICATION_CODE_FILE_NAME="$APPLICATION_CODE_FILE_NAME" `
    --build-arg RDS_ENDPOINT="$RDS_ENDPOINT" `
    --build-arg RDS_DB_NAME="$RDS_DB_NAME" `
    --build-arg RDS_DB_USERNAME="$RDS_DB_USERNAME" `
    -t "${IMAGE_NAME}:${IMAGE_TAG}" `
    .

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker build failed"
    exit 1
}
Write-Host "Docker image built successfully!" -ForegroundColor Green

# Clean up temporary environment variables
Remove-Item Env:\PERSONAL_ACCESS_TOKEN_SECRET -ErrorAction SilentlyContinue
Remove-Item Env:\RDS_DB_PASSWORD_SECRET -ErrorAction SilentlyContinue
Write-Host "Temporary environment variables cleaned up." -ForegroundColor Green

# ================================================================
# Push the image to AWS ECR
# ================================================================

# Check if repository exists, create if it doesn't
Write-Host "Checking if ECR repository exists..." -ForegroundColor Cyan
aws ecr describe-repositories `
    --repository-names "$ECR_REPO_NAME" `
    --region "$AWS_REGION" 2>$null

if ($?) {
    Write-Host "Repository already exists. Skipping creation." -ForegroundColor Green
} else {
    Write-Host "Creating repository..." -ForegroundColor Cyan
    aws ecr create-repository `
        --repository-name "$ECR_REPO_NAME" `
        --region "$AWS_REGION"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create ECR repository"
        exit 1
    }
    Write-Host "Repository created successfully!" -ForegroundColor Green
}

# Tag the image
Write-Host "Tagging Docker image for ECR..." -ForegroundColor Cyan
docker tag "${LOCAL_IMAGE_NAME}:${IMAGE_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker tag failed"
    exit 1
}
Write-Host "Docker image tagged successfully!" -ForegroundColor Green

# Authenticate Docker to ECR
Write-Host "Authenticating Docker to ECR..." -ForegroundColor Cyan
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker login to ECR failed"
    exit 1
}
Write-Host "Docker authenticated to ECR successfully!" -ForegroundColor Green

# Push the image to ECR
Write-Host "Pushing Docker image to ECR..." -ForegroundColor Cyan
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker push to ECR failed"
    exit 1
}
Write-Host "Docker image pushed to ECR successfully!" -ForegroundColor Green

# Print an empty line for better readability
Write-Host ""

# Final success message
Write-Host "========================================" -ForegroundColor Green
Write-Host "All operations completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green