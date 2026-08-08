variable "aws_region" {
  description = "AWS region to deploy into"
  default     = "ap-south-1"
}

variable "project" {
  description = "Short name prefix for all resources"
  default     = "ecs-test"
}

variable "slack_webhook_url" {
  description = "Slack incoming webhook URL"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Optional email to also receive alerts"
  type        = string
  default     = ""
}

variable "cpu_alarm_threshold" {
  description = "CPU % to trigger alarm"
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory % to trigger alarm"
  default     = 80
}

variable "task_count_threshold" {
  description = "Minimum running tasks — alarm if below this"
  default     = 1
}