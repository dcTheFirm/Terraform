output "alb_dns_name" {
  description = "Hit this URL to test your app"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.slack_notifier.function_name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.ecs_app.name
}