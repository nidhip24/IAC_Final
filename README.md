# AWS Infrastructure Deployment with Terraform

This project uses Terraform to create a scalable AWS infrastructure including an S3 bucket for state storage, EC2 instances, and networking components.

## Architecture

The infrastructure includes:
- A custom VPC with a public subnet
- EC2 instance with a public IP
- Security group allowing SSH (port 22) and HTTP/HTTPS (ports 80/443) access
- S3 bucket for Terraform state storage with versioning enabled
- DynamoDB table for state locking

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or newer)
- AWS account and [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- SSH key pair in your AWS account (for EC2 access)

## Setup Instructions

### Initial Setup

1. Clone this repository
2. Create your own `terraform.tfvars` file based on the provided example:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Update the `terraform.tfvars` file with your specific values:
   - Replace `your-keypair-name` with your actual AWS key pair name
   - Update `state_bucket_name` with a globally unique S3 bucket name
   - Adjust any other variables as needed

### First Deployment (Local State)

For the first deployment, you need to use local state to create the S3 bucket and DynamoDB table that will later store your Terraform state:

1. **IMPORTANT**: Make sure the S3 backend configuration in `backend.tf` is commented out for the first run
2. Initialize Terraform with local state:
   ```bash
   terraform init
   ```
3. Apply the configuration to create resources including the S3 bucket:
   ```bash
   terraform apply
   ```

### Migrating to Remote State

After the S3 bucket and DynamoDB table are created, update the backend configuration:

1. Create your own `backend-config.tfvars` file based on the provided example:
   ```bash
   cp backend-config.tfvars.example backend-config.tfvars
   ```
2. Update `backend-config.tfvars` with your actual bucket and DynamoDB table names (matching what you specified in `terraform.tfvars`)
3. Uncomment the backend "s3" {} block in `backend.tf`
4. Re-initialize Terraform to migrate the state to S3:
   ```bash
   terraform init -backend-config=backend-config.tfvars -migrate-state
   ```

### Subsequent Deployments

For all subsequent changes, you can use:

```bash
terraform plan  # Preview changes
terraform apply # Apply changes
```

### Clean Up

To destroy all resources when you're done:

1. If using S3 backend, you must first empty the S3 bucket:
   ```bash
   aws s3 rm s3://YOUR_BUCKET_NAME --recursive
   ```
2. Then destroy the infrastructure:
   ```bash
   terraform destroy
   ```

> **Important**: If you encounter state lock errors during destroy, you may need to force-unlock:
> ```bash
> terraform force-unlock LOCK_ID
> ```
> Replace LOCK_ID with the lock ID from the error message.

## Handling S3 Backend Errors

If you encounter errors related to the S3 backend, try these solutions:

1. **"Bucket not empty" error when deleting S3 bucket**:
   - Empty the bucket first before destroying:
     ```bash
     aws s3 rm s3://your-bucket-name --recursive
     ```

2. **State lock errors**:
   - If a previous operation was interrupted, you may need to force-unlock:
     ```bash
     terraform force-unlock LOCK_ID
     ```
   - If DynamoDB table doesn't exist but is referenced, comment out the backend configuration in `backend.tf` and run:
     ```bash
     terraform init -reconfigure
     ```

## File Structure

- `main.tf`: Main Terraform configuration file with provider and EC2 instance configuration
- `network.tf`: Network infrastructure including VPC, subnets, and routing
- `security.tf`: Security groups and access rules
- `storage.tf`: S3 bucket configuration for state storage
- `dynamodb.tf`: DynamoDB table for state locking
- `variables.tf`: Variable definitions
- `terraform.tfvars`: Variable values (not committed to version control)
- `terraform.tfvars.example`: Example variable values (safe to commit)
- `backend.tf`: Terraform backend configuration
- `backend-config.tfvars`: Backend configuration values (not committed to version control)
- `backend-config.tfvars.example`: Example backend configuration (safe to commit)
- `README.md`: Project documentation

## Best Practices

- Don't commit `terraform.tfvars` or `backend-config.tfvars` to version control as they may contain sensitive information
- Use the provided `.gitignore` file to prevent accidental commits of sensitive files
- Choose strong, unique passwords for your AWS account
- Follow the principle of least privilege when setting up AWS credentials
- Regularly update your Terraform version and provider versions
