# S3 backend with DynamoDB for state locking
terraform {
  backend "s3" {
    bucket         = "dev-nest-terraform-remote-state"
    key            = "terraform-module/nest/ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dev-nest-terraform-locks"
    profile        = "aws-projects" # This profile name must be specified unless the terraform init would not work
  }
}
