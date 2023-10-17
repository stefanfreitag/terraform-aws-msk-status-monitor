variable "email" {
  description = "List of e-mail addresses subscribing to the SNS topic. Default is empty list."
  type        = list(string)
  default     = []
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
