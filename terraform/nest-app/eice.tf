# EC2 Instance Connect Endpoint for private subnet SSH access
resource "aws_ec2_instance_connect_endpoint" "instance_connect_endpoint" {
  subnet_id          = aws_subnet.private_app_subnet_az1.id
  security_group_ids = [aws_security_group.eice_security_group.id]

  tags = {
    Name = "${var.environment}-${var.project-name}-eice"
  }
}