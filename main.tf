# A random identifier used for naming resources
resource "random_id" "id" {
  byte_length = 8
}

# The SNS topic to send notifications to
resource "aws_sns_topic" "msk_health_sns_topic" {
  name              = "msk-health-topic-${random_id.id.hex}"
  kms_master_key_id = "alias/aws/sns"
  tags              = var.tags
}

# SNS subscriptions
resource "aws_sns_topic_subscription" "msk_health_sns_topic_email_target" {
  for_each  = toset(var.email)
  topic_arn = aws_sns_topic.msk_health_sns_topic.arn
  protocol  = "email"
  endpoint  = each.value
}

# IAM role
resource "aws_iam_role" "msk_health_lambda_role" {
  name = "msk-health-lambda-role-${random_id.id.hex}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = var.tags
}

# IAM role attachment
resource "aws_iam_role_policy_attachment" "msk_health_permissions" {
  role       = aws_iam_role.msk_health_lambda_role.name
  policy_arn = aws_iam_policy.msk_health_lambda_role_policy.arn

  depends_on = [aws_iam_policy.msk_health_lambda_role_policy,
  aws_iam_role.msk_health_lambda_role]
}

### TODO: check describe ClusterV2 permissions
# iam policy for lambda role
resource "aws_iam_policy" "msk_health_lambda_role_policy" {
  name        = "msk-health-lambda-role-policy-${random_id.id.hex}"
  path        = "/"
  description = "IAM policy msk health solution lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:log-group:/aws/lambda/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "kafka:ListClusters",
                "kafka:DescribeCluster",
                "kafka:DescribeClusterV2"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "sns:Publish"
            ],
            "Resource": "${aws_sns_topic.msk_health_sns_topic.arn}",
            "Effect": "Allow"
        }
    ]
}
EOF
  tags   = var.tags
}


resource "aws_lambda_function" "msk_health_lambda" {
  filename                       = "${path.module}/python/hello-python.zip"
  function_name                  = "msk_status_monitor-${random_id.id.hex}"
  description                    = "MSK Status Monitor"
  role                           = aws_iam_role.msk_health_lambda_role.arn
  handler                        = "index.lambda_handler"
  runtime                        = "python3.11"
  reserved_concurrent_executions = 1
  memory_size                    = 128
  timeout                        = 60
  tags                           = var.tags

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.msk_health_sns_topic.arn
    }
  }

}

# eventbridge rule
resource "aws_cloudwatch_event_rule" "msk_health_lambda_schedule" {
  name                = "msk-health-eventbridge-rule-${random_id.id.hex}"
  description         = "Scheduled execution of the MSK monitor"
  schedule_expression = var.schedule_expression
  is_enabled          = true
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "msk_health_lambda_target" {
  arn  = aws_lambda_function.msk_health_lambda.arn
  rule = aws_cloudwatch_event_rule.msk_health_lambda_schedule.name
}

resource "aws_lambda_permission" "allow_cw_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.msk_health_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.msk_health_lambda_schedule.arn
}


# Log group for the Lambda function
resource "aws_cloudwatch_log_group" "msk_health_lambda_log_groups" {
  name              = "/aws/lambda/msk_status_monitor-${random_id.id.hex}"
  retention_in_days = 30
  tags              = var.tags
}
