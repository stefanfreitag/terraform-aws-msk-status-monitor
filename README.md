# terraform-aws-msk-health

[![Terraform Version](https://img.shields.io/badge/Terraform%20Version->=1.0-blue.svg)](https://releases.hashicorp.com/terraform/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This module deploys a Lambda function that checks the health of  MSK cluster and sends a notification if a cluster is unhealthy.

If the target for `ok_actions`, `alarm_actions` or `insufficient_data_actions` is an SNS topic using a KMS key, ensure
that CloudWatch Alarms has sufficient permissions to publish messages.
For example:
```shell
statement {
    sid    = "Allow access for CloudWatch Alarms"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

  }
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >=2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >=2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.21.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.status_checker_code](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). Default is `null`. | `list(string)` | `null` | no |
| <a name="input_cloudwatch_alarms_treat_missing_data"></a> [cloudwatch\_alarms\_treat\_missing\_data](#input\_cloudwatch\_alarms\_treat\_missing\_data) | Sets how the alarms handle missing data points. The following values are supported: `missing`, `ignore`, `breaching` and `notBreaching`. Default is `breaching`. | `string` | `"breaching"` | no |
| <a name="input_cluster_arns"></a> [cluster\_arns](#input\_cluster\_arns) | List of MSK cluster ARNs. Default is `[]`. | `list(string)` | `[]` | no |
| <a name="input_email"></a> [email](#input\_email) | List of e-mail addresses subscribing to the SNS topic. Default is `[]`. | `list(string)` | `[]` | no |
| <a name="input_enable_cloudwatch_alarms"></a> [enable\_cloudwatch\_alarms](#input\_enable\_cloudwatch\_alarms) | Setup CloudWatch alarms for the MSK clusters state. For each state a separate alarm will be created. Default is `false`. | `bool` | `false` | no |
| <a name="input_enable_sns_notifications"></a> [enable\_sns\_notifications](#input\_enable\_sns\_notifications) | Setup SNS notifications for the MSK clusters state. Default is `false`. | `bool` | `false` | no |
| <a name="input_ignore_states"></a> [ignore\_states](#input\_ignore\_states) | Suppress warnings for the listed MSK states. Default: ['MAINTENANCE'] | `list(string)` | <pre>[<br/>  "MAINTENANCE"<br/>]</pre> | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). Default is `null`. | `list(string)` | `null` | no |
| <a name="input_log_retion_period_in_days"></a> [log\_retion\_period\_in\_days](#input\_log\_retion\_period\_in\_days) | Number of days logs will be retained. Default is `365`. | `number` | `365` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MByte that the Lambda function can use at runtime. Default is `160`. | `number` | `160` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the health monitor. Default is `msk_status_monitor`. | `string` | `"msk_status_monitor"` | no |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | The schedule expression for the CloudWatch event rule. Default is `rate(5 minutes)`. | `string` | `"rate(5 minutes)"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Default is `{}`. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_metric_alarm_arns"></a> [cloudwatch\_metric\_alarm\_arns](#output\_cloudwatch\_metric\_alarm\_arns) | A map consisting of MSK cluster names and their CloudWatch metric alarm ARNs. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | The ARN of the SNS topic. |
<!-- END_TF_DOCS -->
