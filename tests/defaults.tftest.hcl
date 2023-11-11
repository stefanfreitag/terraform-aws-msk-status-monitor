###
# The schedule expression for the default eventbridge rule should be rate(5 minutes).
###
run "eventbridge_default_schedule_expression" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.msk_health_lambda_schedule.schedule_expression == "rate(5 minutes)"
    error_message = "Schedule expression is not matching expected default value of rate(5 minutes)."
  }
}

##
# The default value for CloudWatch Alarm property treat_missing_data should be set to breaching.
##
run "aws_cloudwatch_metric_alarm_default_treat_missing_data" {
  command = plan
  variables {
    cluster_arns                         = ["arn:aws:kafka:eu-central-1:123456789012:cluster/test/ee779f75-92da-44a3-9f78-3b1af1053651-4"]
    enable_cloudwatch_alarms             = true
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.this["test"].treat_missing_data == "breaching"
    error_message = "The default value for treat_missing_data is not set to breaching."
  }
}
