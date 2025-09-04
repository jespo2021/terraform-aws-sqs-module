# Usage Example - Post Release

After the module is released to GitHub, here's how users would consume it:

## Basic Usage

```hcl
module "my_queue" {
  source = "github.com/intervision/terraform-aws-sqs-module?ref=1.0.0"

  queue_name                 = "my-application-queue"
  message_retention_days     = 14
  visibility_timeout_seconds = 300
  enable_sse                = true

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

## With Dead Letter Queue

```hcl
module "my_queue_with_dlq" {
  source = "github.com/intervision/terraform-aws-sqs-module?ref=1.0.0"

  queue_name                 = "my-application-queue"
  message_retention_days     = 7
  visibility_timeout_seconds = 60
  
  # DLQ Configuration
  create_dead_letter_queue   = true
  max_receive_count         = 3
  dlq_message_retention_days = 14
  
  enable_sse = true

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}

# Access outputs
output "queue_url" {
  value = module.my_queue_with_dlq.queue_url
}

output "queue_arn" {
  value = module.my_queue_with_dlq.queue_arn
}

output "dlq_url" {
  value = module.my_queue_with_dlq.dead_letter_queue_url
}
```

## With S3 Integration

```hcl
module "s3_notification_queue" {
  source = "github.com/intervision/terraform-aws-sqs-module?ref=1.0.0"

  queue_name                 = "s3-notifications"
  message_retention_days     = 3
  visibility_timeout_seconds = 30
  
  # S3 Integration
  allowed_source_account    = "123456789012"
  allowed_source_bucket_arn = "arn:aws:s3:::my-bucket"
  
  enable_sse = true

  tags = {
    Environment = "production"
    Purpose     = "S3 Notifications"
  }
}
```

## Version Pinning

```hcl
# Pin to specific version
module "queue_v1" {
  source = "github.com/intervision/terraform-aws-sqs-module?ref=1.0.0"
  # ... configuration
}

# Use latest from main branch (not recommended for production)
module "queue_latest" {
  source = "github.com/intervision/terraform-aws-sqs-module?ref=main"
  # ... configuration
}

# Use version constraint (when published to Terraform Registry)
module "queue_registry" {
  source  = "intervision/sqs/aws"
  version = "~> 1.0"
  # ... configuration
}
```
