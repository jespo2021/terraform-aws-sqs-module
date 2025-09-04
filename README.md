# AWS SQS Terraform Module

A generic, reusable Terraform module to create and manage AWS SQS queues with optional Dead Letter Queue (DLQ) and secure queue policies. This module supports the functionality used in `42-rapid-deploy-infrastructure/terraform/terraform-bootstrap/modules/sqs` while adhering to organization Terraform standards.

## Features
- Standard SQS queue creation (import-friendly design)
- Optional Dead Letter Queue (DLQ) creation or attachment via ARN
- SQS-managed server-side encryption toggle
- Secure queue policy denying non-SSL access
- Optional S3 -> SQS send permissions by account and/or bucket ARN
- Tags applied to all resources

## Requirements
- Terraform: ~> 1.12.0
- AWS Provider: ~> 5.0

## Usage
```hcl
module "queue" {
  source = "github.com/intervision/terraform-aws-sqs-module?ref=1.0.0"

  queue_name                  = "my-queue"
  message_retention_days      = 14
  visibility_timeout_seconds  = 300
  receive_wait_time_seconds   = 0
  max_message_size            = 262144
  delay_seconds               = 0

  enable_sse = true

  # DLQ options (choose one)
  create_dead_letter_queue = true
  # dead_letter_queue_arn = "arn:aws:sqs:us-east-1:123456789012:my-queue-dlq"

  max_receive_count = 5

  # Optional S3 allow list for notifications
  allowed_source_account    = "123456789012"
  allowed_source_bucket_arn = "arn:aws:s3:::my-bucket"

  tags = {
    Project = "example"
    Env     = "dev"
  }
}
```

## Inputs
- `queue_name` (string, required): Name of the SQS queue
- `message_retention_days` (number, default 14, 1-14): Message retention (days)
- `visibility_timeout_seconds` (number, default 300): Visibility timeout
- `receive_wait_time_seconds` (number, default 0): Long polling wait
- `max_message_size` (number, default 262144): Max message size bytes
- `delay_seconds` (number, default 0): Delivery delay
- `enable_sse` (bool, default false): Enable SQS-managed SSE
- `create_dead_letter_queue` (bool, default false): Create DLQ
- `dead_letter_queue_arn` (string, default null): Existing DLQ ARN to attach
- `max_receive_count` (number, default 5): Receives before moving to DLQ
- `dlq_message_retention_days` (number, default 14): DLQ retention (days)
- `allowed_source_account` (string, default null): Account allowed to send (S3)
- `allowed_source_bucket_arn` (string, default null): S3 bucket ARN allowed to send
- `tags` (map(string), default `{}`): Tags to apply

## Outputs
- `queue_url`: URL of the SQS queue
- `queue_arn`: ARN of the SQS queue
- `queue_name`: Name of the SQS queue
- `dead_letter_queue_url`: URL of the DLQ (if created or provided)
- `dead_letter_queue_arn`: ARN of the DLQ (if created or provided)

## Notes
- KMS CMK encryption is intentionally not included to remain compatible with common S3 -> SQS notification patterns without extra IAM/KMS configuration. Use SQS-managed SSE via `enable_sse` when needed.

## Examples
See `examples/basic` for a minimal example.

