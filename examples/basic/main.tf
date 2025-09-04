terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "sqs" {
  source = "../../" # module root

  queue_name                 = "example-queue"
  message_retention_days     = 7
  visibility_timeout_seconds = 60

  enable_sse                 = true
  create_dead_letter_queue   = true
  max_receive_count          = 3
  dlq_message_retention_days = 14

  tags = {
    Project = "sqs-example"
    Env     = "dev"
  }
}

output "queue_arn" {
  value = module.sqs.queue_arn
}

