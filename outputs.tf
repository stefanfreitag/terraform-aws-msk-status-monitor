output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.msk_health_sns_topic.arn
}

output "role_arn" {
  description = "The ARN of the IAM role."
  value       = aws_iam_role.msk_health_lambda_role.arn
}
