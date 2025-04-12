terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # To use the S3 backend, uncomment the following block after creating the S3 bucket and DynamoDB table
  # To initialize with this backend, run:
  # terraform init -backend-config=backend-config.tfvars -migrate-state
#   backend "s3" {}
} 