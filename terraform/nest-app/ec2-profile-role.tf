# IAM role for EC2 instances for S3 access
resource "aws_iam_role" "s3_full_access_role" {
  name = "${var.environment}-${var.project-name}-s3-full-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach S3 full access policy to the role
resource "aws_iam_role_policy_attachment" "s3_full_access_attachment" {
  role       = aws_iam_role.s3_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Instancesz profile for EC2 instances to assume the role
resource "aws_iam_instance_profile" "s3_full_access_instance_profile" {
  name = "${var.environment}-${var.project-name}-s3-full-access-instance-profile"
  role = aws_iam_role.s3_full_access_role.name
}