# terraform-aws-msk-health

[![Terraform Version](https://img.shields.io/badge/Terraform%20Version->=1.0-blue.svg)](https://releases.hashicorp.com/terraform/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This module deploys a Lambda function that checks the health of  MSK cluster and sends a notification if a cluster is unhealthy.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >=2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >=2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.msk_health_lambda_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.msk_health_lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.msk_health_lambda_log_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.msk_health_lambda_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.msk_health_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.msk_health_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.msk_health_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cw_call_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.msk_health_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.msk_health_sns_topic_email_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [archive_file.status_checker_code](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_arns"></a> [cluster\_arns](#input\_cluster\_arns) | List of MSK cluster ARNs. Default is empty list. | `list(string)` | `[]` | no |
| <a name="input_email"></a> [email](#input\_email) | List of e-mail addresses subscribing to the SNS topic. Default is empty list. | `list(string)` | `[]` | no |
| <a name="input_enable_cloudwatch_alarms"></a> [enable\_cloudwatch\_alarms](#input\_enable\_cloudwatch\_alarms) | Setup CloudWatch alarms for the MSK clusters state. For each state a separate alarm will be created. Default is false. | `bool` | `false` | no |
| <a name="input_enable_sns_notifications"></a> [enable\_sns\_notifications](#input\_enable\_sns\_notifications) | Setup SNS notifications for the MSK clusters state. Default is false. | `bool` | `false` | no |
| <a name="input_ignore_states"></a> [ignore\_states](#input\_ignore\_states) | Suppress warnings for the listed MSK states. Default: ['MAINTENANCE'] | `list(string)` | <pre>[<br>  "MAINTENANCE"<br>]</pre> | no |
| <a name="input_log_retion_period_in_days"></a> [log\_retion\_period\_in\_days](#input\_log\_retion\_period\_in\_days) | Number of days logs will be retained. Default is 365 days. | `number` | `365` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MByte that the Lambda Function can use at runtime. Default is 160. | `number` | `160` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | The schedule expression for the CloudWatch event rule. Default is 'rate(5 minutes)'. | `string` | `"rate(5 minutes)"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Default is empty map. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | The ARN of the SNS topic. |
<!-- END_TF_DOCS -->
