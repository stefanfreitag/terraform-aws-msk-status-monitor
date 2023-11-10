output "cloudwatch_alert_arns" {
  description = "A map consisting of MSK cluster names and their CloudWatch metric alarm ARNs."
  value       = module.msk_monitor.cloudwatch_metric_alarm_arns
}
