variable "cluster_arns" {
  description = "List of MSK cluster ARNs. Default is `[]`."
  type        = list(string)
  default     = []
}

variable "email" {
  description = "List of e-mail addresses subscribing to the SNS topic. Default is `[]`."
  type        = list(string)
  default     = []
}

variable "enable_cloudwatch_alarms" {
  description = "Setup CloudWatch alarms for the MSK clusters state. For each state a separate alarm will be created. Default is `false`."
  type        = bool
  default     = false
}

variable "cloudwatch_alarms_treat_missing_data" {
  description = "Sets how the alarms handle missing data points. The following values are supported: `missing`, `ignore`, `breaching` and `notBreaching`. Default is `breaching`."
  type        = string
  default     = "breaching"
  validation {
    condition     = can(regex("^(missing|ignore|breaching|notBreaching)$", var.cloudwatch_alarms_treat_missing_data))
    error_message = "The value must be one of missing, ignore, breaching or notBreaching."
  }
}

variable "enable_sns_notifications" {
  description = "Setup SNS notifications for the MSK clusters state. Default is `false`."
  type        = bool
  default     = false
}

variable "ignore_states" {
  description = "Suppress warnings for the listed MSK states. Default: ['MAINTENANCE']"
  type        = list(string)
  default = [
    "MAINTENANCE"
  ]
}

variable "log_retion_period_in_days" {
  type        = number
  default     = 365
  description = "Number of days logs will be retained. Default is `365`."

  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
    400, 545, 731, 1096, 1827, 2192, 2557, 2992, 3288, 3653], var.log_retion_period_in_days)
    error_message = "log_retion_period_in_days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653"
  }
}

variable "name" {
  type        = string
  description = "Name of the health monitor. Default is `msk_status_monitor`."
  default     = "msk_status_monitor"
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MByte that the Lambda function can use at runtime. Default is `160`."
  default     = 160
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128 and 10240"
  }
}

variable "schedule_expression" {
  description = "The schedule expression for the CloudWatch event rule. Default is `rate(5 minutes)`."
  type        = string
  default     = "rate(5 minutes)"
}

variable "tags" {
  description = "A map of tags to add to all resources. Default is `{}`."
  type        = map(string)
  default = {
  }
}
