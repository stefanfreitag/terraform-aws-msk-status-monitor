# AWS account information
data "aws_caller_identity" "current" {}

# AWS region information
data "aws_region" "current" {}

# Creates a zip file for the check-msk-status Lambda function
data "archive_file" "status_checker_code" {
  type                        = "zip"
  source_dir                  = "${path.module}/functions/check-msk-status/"
  output_path                 = "${path.module}/out/check-msk-status.zip"
  exclude_symlink_directories = false
  output_file_mode            = "0666"
}
