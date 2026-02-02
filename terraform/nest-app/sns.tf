# SNS topics
resource "aws_sns_topic" "user_updates" {
  name = "${var.environment}-${var.project-name}-sns-topic"
}

# Email subscription
resource "aws_sns_topic_subscription" "notification_topic" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = var.operator_mail
}