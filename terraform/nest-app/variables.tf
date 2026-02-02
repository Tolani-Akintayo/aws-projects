# Environment variable for AWS region
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "project-name" {
  description = "The AWS project name for tagging and identification"
  type        = string
}

variable "environment" {
  description = "The AWS environment (e.g., dev, staging, prod)"
  type        = string
}

variable "project-directory" {
  description = "The directory of the project"
  type        = string
}

# VPC
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "Public subnet AZ1 CIDR"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "Public subnet AZ2 CIDR"
  type        = string
}

variable "private_app_subnet_az1_cidr" {
  description = "Private app subnet AZ1 CIDR"
  type        = string
}

variable "private_app_subnet_az2_cidr" {
  description = "Private app subnet AZ2 CIDR"
  type        = string
}

variable "private_data_subnet_az1_cidr" {
  description = "Private data subnet AZ1 CIDR"
  type        = string
}

variable "private_data_subnet_az2_cidr" {
  description = "Private data subnet AZ2 CIDR"
  type        = string
}

# Secrets Manager
variable "db_secret_name" {
  description = "The name of the Secrets Manager secret for database credentials"
  type        = string
}

# RDS
variable "multi_az_deployment" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
}

variable "database_instance_identifier" {
  description = "The RDS database instance identifier"
  type        = string
}

variable "database_instance_class" {
  description = "RDS instance class (e.g db.t3.micro)"
  type        = string
}

variable "database_engine" {
  description = "Database engine (mysql, postgres, mariadb)"
  type        = string
}

variable "database_engine_version" {
  description = "Database engine version (e.g., 8.039)"
  type        = string
}

variable "publicly_accessible" {
  description = "Makes RDS instance is publicly accessible"
  type        = bool
}

# EC2
variable "amazon_linux_ami_id" {
  description = "The AMI ID for Amazon Linux"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type for application servers (e.g., t2.micro)"
  type        = string
}

variable "flyway_version" {
  description = "Version of Flyway to use for database migrations"
  type        = string
}

variable "sql_script_s3_uri" {
  description = "S3 URI for the SQL migration script"
  type        = string
}

# ACM
variable "domain_name" {
  description = "Primary domain name for the ACM certificate"
  type        = string
}

variable "alternative_names" {
  description = "Alternative domain names (SANs) for the ACM certificate"
  type        = string
}

# ALB
variable "target_type" {
  description = "Target type (ip, instance, lambda)"
  type        = string
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/"
}

# SNS
variable "operator_mail" {
  description = "Email for SNS notifications"
  type        = string
}

# Route 53
variable "record_name" {
  description = "Route 53 record name"
  type        = string
}

# ASG
variable "web_files_s3_uri" {
  description = "S3 URI for application code"
  type        = string
}

variable "service_provider_file_s3_uri" {
  description = "S3 URI for service provider file"
  type        = string
}

variable "application_code_file_name" {
  description = "Filename for the application code"
  type        = string
}