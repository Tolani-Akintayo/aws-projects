# Launch Template for Auto Scaling Group
resource "aws_launch_template" "app_server_launch_template" {
  name_prefix            = "${var.environment}-${var.project-name}-lt"
  image_id               = var.amazon_linux_ami_id
  instance_type          = var.ec2_instance_type
  description            = "${var.environment}-${var.project-name}-lt"
  vpc_security_group_ids = [aws_security_group.app_security_group.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.s3_full_access_instance_profile.name
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(templatefile("${path.module}/deployment-script.sh.tpl", {
    PROJECT_NAME                 = var.project-name
    ENVIRONMENT                  = var.environment
    RECORD_NAME                  = var.record_name
    DOMAIN_NAME                  = var.domain_name
    WEB_FILES_S3_URI             = var.web_files_s3_uri
    SERVICE_PROVIDER_FILE_S3_URI = var.service_provider_file_s3_uri
    APPLICATION_CODE_FILE_NAME   = var.application_code_file_name
    RDS_ENDPOINT                 = aws_db_instance.atabase_instance.endpoint
    RDS_DB_NAME                  = local.secrets.db_name
    RDS_USERNAME                 = local.secrets.username
    RDS_PASSWORD                 = local.secrets.password
  }))
}

# Auto Scaling Group for application servers
resource "aws_autoscaling_group" "auto_scaling_group" {
  vpc_zone_identifier = [aws_subnet.private_app_subnet_az1.id, aws_subnet.private_app_subnet_az2.id]
  name                = "${var.environment}-${var.project-name}-asg"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app_server_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-${var.project-name}-web-server"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes        = [target_group_arns]
    create_before_destroy = false
  }

  depends_on = [aws_instance.data_migrate_server]
}

# Attach ASG to ALB Target Group
resource "aws_autoscaling_attachment" "asg_alb_target_group_attachment" {
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name
  lb_target_group_arn    = aws_lb_target_group.app_target_group.arn

  depends_on = [aws_autoscaling_group.auto_scaling_group]
}

# SNS notifications for ASG events
resource "aws_autoscaling_notification" "webserver_asg-notifications" {
  group_names = [aws_autoscaling_group.auto_scaling_group.name]
  topic_arn   = aws_sns_topic.user_updates.arn
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
}