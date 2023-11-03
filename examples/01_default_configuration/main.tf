module "msk_monitor" {
  source                   = "../.."
  cluster_arns             = []
  enable_cloudwatch_alarms = true
  schedule_expression      = "rate(2 minutes)"
  tags = {
    "Name" = "msk-monitor"
  }
}
