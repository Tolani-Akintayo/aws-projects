# Create VPC
module "vpc" {
  source                       = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//vpc"
  region                       = "us-east-1"
  project_name                 = "nest"
  environment                  = "dev"
  project_directory            = "nest-app"
  vpc_cidr                     = "10.0.0.0/16"
  public_subnet_az1_cidr       = "10.0.0.0/24"
  public_subnet_az2_cidr       = "10.0.1.0/24"
  private_app_subnet_az1_cidr  = "10.0.2.0/24"
  private_app_subnet_az2_cidr  = "10.0.3.0/24"
  private_data_subnet_az1_cidr = "10.0.4.0/24"
  private_data_subnet_az2_cidr = "10.0.5.0/24"
}

# Create NAT gateway
module "nat-gateway" {
  source                     = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//nat-gateway"
  environment                = module.vpc.environment
  project_name               = module.vpc.project_name
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  internet_gateway           = module.vpc.internet_gateway
  vpc_id                     = module.vpc.vpc_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
}

# Create Security groups
module "security-groups" {
  source       = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//security-groups"
  environment  = module.vpc.environment
  project_name = module.vpc.project_name
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = module.vpc.vpc_cidr

}

# Create EICE
module "eice" {
  source                    = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//eice"
  environment               = module.vpc.environment
  project_name              = module.vpc.project_name
  private_app_subnet_az1_id = module.vpc.private_app_subnet_az1_id
  eice_security_group_id    = module.security-groups.eice_security_group_id
}

# Get secrets from secrets manager
module "secrets-manager" {
  source    = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//secrets-manager"
  secret_id = "dev_db_credentials"
}

# Create RDS Instance
module "rds" {
  source                       = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//rds"
  region                       = module.vpc.region
  environment                  = module.vpc.environment
  project_name                 = module.vpc.environment
  multi_az_deployment          = false
  database_instance_identifier = "dev-nest-db"
  database_instance_class      = "db.t3.micro"
  database_engine              = "mysql"
  database_engine_version      = "8.0.43"
  publicly_accessible          = false
  private_data_subnet_az1_id   = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id   = module.vpc.private_data_subnet_az2_id
  rds_db_username              = module.secrets-manager.rds_db_username
  rds_db_password              = module.secrets-manager.rds_db_password
  rds_db_secret_name           = module.secrets-manager.rds_db_secret_name
  database_security_group_id   = module.security-groups.database_security_group_id
  availability_zone_1          = module.vpc.availability_zone_1
}

# Create EC2 Instance Profile 
module "ec2_instance_profile" {
  source       = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//iam/ec2-instance-profile"
  environment  = module.vpc.environment
  project_name = module.vpc.environment
}

# Create database migration server
module "database-migration-server" {
  source                                  = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//data-migrate"
  environment                             = module.vpc.environment
  project_name                            = module.vpc.environment
  amazon_linux_ami_id                     = "ami-02dfbd4ff395f2a1b"
  ec2_instance_type                       = "t2.micro"
  private_app_subnet_az1_id               = module.vpc.private_app_subnet_az1_id
  data_migration_server_security_group_id = module.security-groups.data_migration_server_security_group_id
  ec2_instance_instance_profile_role_name = module.ec2_instance_profile.ec2_instance_instance_profile_role_name
  flyway_version                          = "11.20.0"
  sql_script_s3_uri                       = "s3://dev-nest-webfiles/project-1-assests/V1__nest.sql"
  rds_endpoint                            = module.rds.rds_endpoint
  rds_db_secret_name                      = module.secrets-manager.rds_db_secret_name
  rds_db_username                         = module.secrets-manager.rds_db_username
  rds_db_password                         = module.secrets-manager.rds_db_password
}

# Create ACM certificate and validate it using Route 53
module "acm" {
  source            = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//acm"
  domain_name       = "akcloudguru.com"
  alternative_names = "*.akcloudguru.com"
}

# # Create Application Load Balancer
module "alb" {
  source                = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//alb"
  environment           = module.vpc.environment
  project_name          = module.vpc.environment
  alb_security_group_id = module.security-groups.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  target_type           = "ip"
  vpc_id                = module.vpc.vpc_id
  health_check_path     = "/index.php"
  acm_certificate_arn   = module.acm.acm_certificate_arn
}

# Create ECS role
module "ecs_role" {
  source       = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//iam/ecs-task-execution-role"
  environment  = module.vpc.environment
  project_name = module.vpc.environment
}

# Create ECS 
module "ecs" {
  source                      = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//ecs"
  region                      = module.vpc.region
  environment                 = module.vpc.environment
  project_name                = module.vpc.environment
  task_cpu                    = 2048
  task_memory                 = 4096
  ecs_task_execution_role_arn = module.ecs_role.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.ecs_role.ecs_task_role_arn
  architecture                = "x86_64"
  container_image             = "195519409709.dkr.ecr.us-east-1.amazonaws.com/nest:latest"
  container_port              = 80
  host_port                   = 80
  service_desired_count       = 2
  private_app_subnet_az1_id   = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id   = module.vpc.private_app_subnet_az2_id
  app_security_group_id       = module.security-groups.app_security_group_id
  alb_target_group_arn        = module.alb.alb_target_group_arn
  depends_on                  = [module.database-migration-server]
}

# Create a record set in Route 53
module "route53" {
  source                             = "git::ssh://git@github.com/Tolani-Akintayo/modules.git//route-53"
  domain_name                        = module.acm.domain_name
  record_name                        = "www"
  application_load_balancer_dns_name = module.alb.application_load_balancer_dns_name
  application_load_balancer_zone_id  = module.alb.application_load_balancer_zone_id
}

# Website URL
output "website_url" {
  value = "http://${module.route53.record_name}.${module.acm.domain_name}"
}

# # Variables to be used by github actions workflow
# output "domain_name" {
#   value = module.acm.domain_name
# }

# output "rds_endpoint" {
#   value = module.rds.rds_endpoint
# }

# output "ecs_task_definition_name" {
#   value = module.ecs.ecs_task_definition_name
# }

# output "ecs_cluster_name" {
#   value = module.ecs.ecs_cluster_name
# }

# output "ecs_service_name" {
#   value = module.ecs.ecs_service_name
# }
