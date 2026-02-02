# EC2 instance for database migration
resource "aws_instance" "data_migrate_server" {
  ami                    = var.amazon_linux_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.private_app_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.data_migration_server_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.s3_full_access_instance_profile.name

  user_data_base64 = base64encode(templatefile("${path.module}/db-migrate-script.sh.tpl", {
    FLYWAY_VERSION    = var.flyway_version
    SQL_SCRIPT_S3_URI = var.sql_script_s3_uri
    RDS_ENDPOINT      = aws_db_instance.database_instance.endpoint
    RDS_DB_NAME       = local.secrets.db_name
    RDS_DB_USERNAME   = local.secrets.username
    RDS_DB_PASSWORD   = local.secrets.password
  }))

  depends_on = [aws_db_instance.database_instance]

  tags = {
    Name = "${var.environment}-${var.project-name}-db-migrate"
  }
}