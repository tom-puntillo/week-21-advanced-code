# Specify the S3 bucket as the backend for Terraform state storage
terraform {
  backend "s3" {
    bucket = "my-terraform-luit-week21-state-tjp" # Replace with your S3 bucket name
    key    = "aws/terraform"                      # Replace with the desired path to the state file within the bucket
    region = "us-east-1"                          # Replace with your desired AWS region for the S3 bucket
  }

  # Define the required version of Terraform for this configuration
  required_version = ">= 1.0.0"

  # Specify the required providers and their versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0" # Require version 3.0 or higher of the AWS provider
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0" # Require version 3.4.0 of the HTTP provider
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0" # Require version 3.1.0 of the Random provider
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0" # Require version 2.4.0 of the Local provider
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4" # Require version 4.0.4 of the TLS provider
    }
  }
}
