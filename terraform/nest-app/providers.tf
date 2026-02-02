# AWS provider
provider "aws" {
  region  = var.region
  profile = "cloud-project"

  default_tags {
    tags = {
      "Automation " = "terraform"
      "Project"     = var.project-name
      "Environment" = var.environment
    }
  }
}

 