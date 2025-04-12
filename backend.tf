terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # IMPORTANT: For first deployment, keep this backend block commented out
  # After S3 bucket is created, uncomment this block and run:
  # terraform init -backend-config=backend-config.tfvars -migrate-state
  #
  # backend "s3" {}
} 