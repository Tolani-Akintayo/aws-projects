# Environment
region            = "us-east-2"
project-name      = "nest"
environment       = "dev"
project-directory = "nest-app"

# # VPC
vpc_cidr                     = "10.0.0.0/16"
public_subnet_az1_cidr       = "10.0.0.0/24"
public_subnet_az2_cidr       = "10.0.1.0/24"
private_app_subnet_az1_cidr  = "10.0.2.0/24"
private_app_subnet_az2_cidr  = "10.0.3.0/24"
private_data_subnet_az1_cidr = "10.0.4.0/24"
private_data_subnet_az2_cidr = "10.0.5.0/24"

# Secrets Manager
db_secret_name = "dev-nest-secret-1"

# RDS Database
multi_az_deployment          = false
database_instance_identifier = "dev-app-db"
database_instance_class      = "db.t3.micro"
database_engine              = "mysql"
database_engine_version      = "8.0.43"
publicly_accessible          = false

# EC2
amazon_linux_ami_id = "ami-03ea746da1a2e36e7" # Amazon Linux 2023 AMI (HVM), SSD Volume Type
ec2_instance_type   = "t2.micro"
flyway_version      = "11.20.0"
sql_script_s3_uri   = "s3://dev-tolani-webfiles/project-2-assests/V1__nest.sql"

# ACM
domain_name       = "tolaniakintayo.xyz"
alternative_names = "*.tolaniakintayo.xyz"

# ALB
target_type       = "instance"
health_check_path = "/index.php"

#  Route 53
operator_mail = "learningdevopsfromscratch@gmail.com"

# Route 53
record_name = "www"

# ASG
web_files_s3_uri             = "s3://dev-tolani-webfiles/project-2-assests/nest.zip"
service_provider_file_s3_uri = "s3://dev-tolani-webfiles/project-2-assests/AppServiceProvider.php"
application_code_file_name   = "nest"
