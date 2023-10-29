variable "email" {
  description = "List of e-mail addresses subscribing to the SNS topic. Default is empty list."
  type        = list(string)
  default     = []
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
  description = "Number of days logs will be retained. Default is 365 days."

  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
    400, 545, 731, 1096, 1827, 2192, 2557, 2992, 3288, 3653], var.log_retion_period_in_days)
    error_message = "log_retion_period_in_days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653"
  }
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MByte that the Lambda Function can use at runtime. Default is 160."
  default     = 160
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128 and 10240"
  }
}

variable "schedule_expression" {
  description = "The schedule expression for the CloudWatch event rule. Default is 'rate(15 minutes)'."
  type        = string
  default     = "rate(15 minutes)"
}

variable "tags" {
  description = "A map of tags to add to all resources. Default is empty map."
  type        = map(string)
  default = {
  }
}
