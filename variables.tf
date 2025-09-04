variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "message_retention_days" {
  description = "Number of days to retain messages (1-14)"
  type        = number
  default     = 14
  validation {
    condition     = var.message_retention_days >= 1 && var.message_retention_days <= 14
    error_message = "Message retention must be between 1 and 14 days."
  }
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 300
  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "Visibility timeout must be between 0 and 43200 seconds (12 hours)."
  }
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time in seconds"
  type        = number
  default     = 0
  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "Receive wait time must be between 0 and 20 seconds."
  }
}

variable "max_message_size" {
  description = "Maximum message size in bytes"
  type        = number
  default     = 262144
  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144
    error_message = "Maximum message size must be between 1024 and 262144 bytes (1KB to 256KB)."
  }
}

variable "delay_seconds" {
  description = "Delivery delay in seconds"
  type        = number
  default     = 0
  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "Delay seconds must be between 0 and 900 seconds (15 minutes)."
  }
}

variable "enable_sse" {
  description = "Enable SQS-managed server-side encryption"
  type        = bool
  default     = false
}

variable "create_dead_letter_queue" {
  description = "Create a dead letter queue"
  type        = bool
  default     = false
}

variable "dead_letter_queue_arn" {
  description = "ARN of an existing dead letter queue to attach (overrides creation if provided)"
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Maximum receives before sending to DLQ"
  type        = number
  default     = 5
  validation {
    condition     = var.max_receive_count >= 1 && var.max_receive_count <= 1000
    error_message = "Maximum receive count must be between 1 and 1000."
  }
}

variable "dlq_message_retention_days" {
  description = "DLQ message retention in days"
  type        = number
  default     = 14
  validation {
    condition     = var.dlq_message_retention_days >= 1 && var.dlq_message_retention_days <= 14
    error_message = "DLQ message retention must be between 1 and 14 days."
  }
}

variable "allowed_source_account" {
  description = "AWS account ID allowed to send messages (e.g., from S3 notifications)"
  type        = string
  default     = null
}

variable "allowed_source_bucket_arn" {
  description = "S3 bucket ARN allowed to send messages"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all created resources"
  type        = map(string)
  default     = {}
}

