# Generic AWS SQS Queue Module
# Provides creation of a standard or imported SQS queue, optional DLQ, and optional S3->SQS permissions

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Compute effective DLQ ARN: prefer provided ARN, else created DLQ if enabled, else null
  effective_dlq_arn = coalesce(
    var.dead_letter_queue_arn,
    try(aws_sqs_queue.dead_letter[0].arn, null)
  )

  # Compute effective DLQ URL: only available for created DLQ, not external ARN
  effective_dlq_url = var.create_dead_letter_queue ? try(aws_sqs_queue.dead_letter[0].id, null) : null

  message_retention_seconds = var.message_retention_days * 24 * 60 * 60
  dlq_retention_seconds     = var.dlq_message_retention_days * 24 * 60 * 60
}

resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  message_retention_seconds  = local.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds

  # SQS-managed SSE (compatible with S3 notifications)
  sqs_managed_sse_enabled = var.enable_sse

  # Redrive policy when DLQ is provided or created
  redrive_policy = local.effective_dlq_arn != null ? jsonencode({
    deadLetterTargetArn = local.effective_dlq_arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge(var.tags, { Name = var.queue_name })
}

# Queue policy with secure transport and optional S3 permissions
resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        # Deny non-SSL connections
        {
          Sid       = "DenyInsecureConnections"
          Effect    = "Deny"
          Principal = "*"
          Action    = "sqs:*"
          Resource  = aws_sqs_queue.this.arn
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
        }
      ],
      # Allow S3 to send messages from a specific account
      var.allowed_source_account != null ? [
        {
          Sid    = "AllowS3BucketNotificationAccount"
          Effect = "Allow"
          Principal = {
            Service = "s3.amazonaws.com"
          }
          Action   = "sqs:SendMessage"
          Resource = aws_sqs_queue.this.arn
          Condition = {
            StringEquals = {
              "aws:SourceAccount" = var.allowed_source_account
            }
          }
        }
      ] : [],
      # Allow S3 to send messages from a specific bucket ARN
      var.allowed_source_bucket_arn != null ? [
        {
          Sid    = "AllowSpecificBucketArn"
          Effect = "Allow"
          Principal = {
            Service = "s3.amazonaws.com"
          }
          Action   = "sqs:SendMessage"
          Resource = aws_sqs_queue.this.arn
          Condition = {
            ArnEquals = {
              "aws:SourceArn" = var.allowed_source_bucket_arn
            }
          }
        }
      ] : []
    )
  })
}

# Optional Dead Letter Queue
resource "aws_sqs_queue" "dead_letter" {
  count = var.create_dead_letter_queue ? 1 : 0

  name                      = "${var.queue_name}-dlq"
  message_retention_seconds = local.dlq_retention_seconds
  sqs_managed_sse_enabled   = var.enable_sse

  tags = merge(var.tags, {
    Name = "${var.queue_name}-dlq"
    Type = "DeadLetterQueue"
  })
}

