terraform {
  required_version = ">= 1.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">=2.4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.32"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.5.1"
    }
  }
}
