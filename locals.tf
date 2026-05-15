locals {
  cluster_names = var.enable_cloudwatch_alarms ? sort([for arn in var.cluster_arns : element(split("/", arn), 1)]) : []
}
