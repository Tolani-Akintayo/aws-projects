# S3 backend with DynamoDB for state locking
terraform {
  backend "s3" {
    bucket         = "tolani-terraform-remote-state"
    key            = "nest-app/ec2/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    profile        = "cloud-project" # This profile name must be specified unless the terraform init would not work
  }
}
