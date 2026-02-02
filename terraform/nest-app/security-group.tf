resource "aws_security_group" "eice_security_group" {
  name        = "${var.environment}-${var.project-name}-eice-sg"
  description = "Outbound SSH to the VPC CIDR"
  vpc_id      = aws_vpc.vpc.id

  egress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.environment}-${var.project-name}-eice-sg"
  }
}

# Security group for Application Load Balancer
resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-${var.project-name}-alb-sg"
  description = "HTTP/HTTPS from the internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project-name}-alb-sg"
  }
}

# Security group for application servers (ECS, EC2)
resource "aws_security_group" "app_security_group" {
  name        = "${var.environment}-${var.project-name}-app-sg"
  description = "HTTP/HTTPS from ALB, SSH from EICE"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "SSH from EICE SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eice_security_group.id]
  }

  ingress {
    description     = "HTTP from ALB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    description     = "HTTPS from ALB SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project-name}-app-sg"
  }
}

# Security group for data migration servers 
resource "aws_security_group" "data_migration_server_security_group" {
  name        = "${var.environment}-${var.project-name}-dms-sg"
  description = "SSH from EICE"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "SSH from EICE SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eice_security_group.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project-name}-dms-sg"
  }
}

# Security group for database (RDS, Aurora)
resource "aws_security_group" "database_security_group" {
  name        = "${var.environment}-${var.project-name}-db-sg"
  description = "MySQL/Aurora access from app and migration servers"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "MySQL/Aurora from App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_security_group.id]
  }

  ingress {
    description     = "MySQL/Aurora from data migration SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.data_migration_server_security_group.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project-name}-db-sg"
  }
}
