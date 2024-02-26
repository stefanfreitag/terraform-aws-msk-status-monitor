module "msk_monitor_1" {
  source                   = "../.."
  cluster_arns             = []
  enable_cloudwatch_alarms = false
  enable_sns_notifications = false
  name                     = "monitor-1"
  schedule_expression      = "rate(2 minutes)"
  tags = {
    "Name"        = "monitor-1"
    "Environment" = "development"
  }
}
