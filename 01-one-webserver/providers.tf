terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
  }
