###
# The SNS topic to send notifications to.
##
resource "aws_sns_topic" "this" {
  name              = var.name
  display_name      = var.name
  fifo_topic        = false
  kms_master_key_id = "alias/aws/sns"
  tags              = var.tags
}

###
# E-Mail based subscriptions to the SNS topic.
###
resource "aws_sns_topic_subscription" "this" {
  for_each  = toset(var.email)
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}

###
# IAM role
###
resource "aws_iam_role" "this" {
  name        = var.name
  description = var.name

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

###
# IAM role attachment
###
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn

  depends_on = [aws_iam_policy.this,
  aws_iam_role.this]
}

resource "aws_iam_policy" "this" {
  name        = var.name
  path        = "/"
  description = var.name
  policy      = <<EOF
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
                "kafka:ListClustersV2"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "kafka:DescribeClusterV2"
            ],
            "Resource": "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/*",
            "Effect": "Allow"
        },
        {
          "Action": [
               "cloudwatch:PutMetricData"
          ],
          "Resource": "*",
          "Effect": "Allow"
        },
        {
            "Action": [
                "sns:Publish"
            ],
            "Resource": "${aws_sns_topic.this.arn}",
            "Effect": "Allow"
        }
    ]
}
EOF
  tags        = var.tags
}

###
# Lambda function executing the health checks
###
resource "aws_lambda_function" "this" {
  filename                       = data.archive_file.status_checker_code.output_path
  function_name                  = var.name
  description                    = var.name
  role                           = aws_iam_role.this.arn
  handler                        = "index.lambda_handler"
  runtime                        = "python3.11"
  reserved_concurrent_executions = 1
  memory_size                    = var.memory_size
  source_code_hash               = data.archive_file.status_checker_code.output_base64sha256
  timeout                        = 60
  tags                           = var.tags
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      CLUSTER_ARNS              = join(",", var.cluster_arns)
      SNS_TOPIC_ARN             = aws_sns_topic.this.arn
      ENABLE_CLOUDWATCH_METRICS = var.enable_cloudwatch_alarms
      ENABLE_SNS_NOTIFICATIONS  = var.enable_sns_notifications
      SUPPRESS_STATES           = join(",", var.ignore_states)
    }
  }

}

# eventbridge rule
resource "aws_cloudwatch_event_rule" "this" {
  name                = var.name
  description         = "Scheduled execution of the MSK monitor"
  schedule_expression = var.schedule_expression
  is_enabled          = true
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  arn  = aws_lambda_function.this.arn
  rule = aws_cloudwatch_event_rule.this.name
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}


# Log group for the Lambda function
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retion_period_in_days
  tags              = var.tags
}


resource "aws_cloudwatch_metric_alarm" "this" {
  for_each                  = toset(local.cluster_names)
  namespace                 = "Custom/Kafka"
  period                    = 300
  metric_name               = "Status"
  alarm_name                = "${var.name}-${each.key}"
  comparison_operator       = "GreaterThanThreshold"
  alarm_description         = "This alarm triggers on MSK cluster status."
  evaluation_periods        = 2
  statistic                 = "Average"
  threshold                 = 0
  treat_missing_data        = var.cloudwatch_alarms_treat_missing_data
  alarm_actions             = []
  insufficient_data_actions = []
  # TODO:  ok_actions                = [var.sns_topic_alarms_arn]
  dimensions = {
    ClusterName = each.key
  }
  tags = var.tags
}

locals {
  cluster_names = var.enable_cloudwatch_alarms ? sort([for arn in var.cluster_arns : element(split("/", arn), 1)]) : []
}
