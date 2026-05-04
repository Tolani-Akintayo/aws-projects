# AWS provider
provider "aws" {
  region  = "us-east-1"
  profile = "aws-projects" # This profile name must be specified unless the terraform plan/apply would not work

  default_tags {
    tags = {
      "Automation"  = "terraform"
      "Project"     = "nest"
      "Environment" = "dev"
    }
  }
}

 