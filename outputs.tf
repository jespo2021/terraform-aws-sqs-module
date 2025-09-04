output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "Name of the SQS queue"
  value       = var.queue_name
}

output "dead_letter_queue_url" {
  description = "URL of the dead letter queue (only available if created by this module)"
  value       = local.effective_dlq_url
}

output "dead_letter_queue_arn" {
  description = "ARN of the dead letter queue (if created or provided)"
  value       = local.effective_dlq_arn
}

