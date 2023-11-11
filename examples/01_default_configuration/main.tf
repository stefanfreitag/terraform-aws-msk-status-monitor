module "msk_monitor" {
  source                   = "../.."
  cluster_arns             = []
  enable_cloudwatch_alarms = false
  enable_sns_notifications = false
  schedule_expression      = "rate(2 minutes)"
  tags = {
    "Name" = "msk-monitor"
  }
}
