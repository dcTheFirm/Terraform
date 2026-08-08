locals {
  sns_arn      = aws_sns_topic.alerts.arn
  cluster_name = aws_ecs_cluster.main.name
  service_name = aws_ecs_service.app.name

  # Extract ARN suffixes CloudWatch needs (format: app/name/id)
  alb_arn_suffix = aws_lb.main.arn_suffix
  tg_arn_suffix  = aws_lb_target_group.app.arn_suffix
}

# ── CPU Utilization ───────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-cpu-high"
  alarm_description   = "ECS service CPU > ${var.cpu_alarm_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = local.cluster_name
    ServiceName = local.service_name
  }

  alarm_actions = [local.sns_arn]
  ok_actions    = [local.sns_arn]
}

# ── Memory Utilization ────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.project}-memory-high"
  alarm_description   = "ECS service Memory > ${var.memory_alarm_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = local.cluster_name
    ServiceName = local.service_name
  }

  alarm_actions = [local.sns_arn]
  ok_actions    = [local.sns_arn]
}

# ── Running Task Count ────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "task_count_low" {
  alarm_name          = "${var.project}-tasks-low"
  alarm_description   = "Running tasks dropped below ${var.task_count_threshold}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = var.task_count_threshold
  treat_missing_data  = "breaching" # no data = tasks are gone = ALARM

  dimensions = {
    ClusterName = local.cluster_name
    ServiceName = local.service_name
  }

  alarm_actions = [local.sns_arn]
  ok_actions    = [local.sns_arn]
}

# ── Target 5XX Errors ─────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name          = "${var.project}-target-5xx"
  alarm_description   = "ALB target 5XX errors > 10 in 1 minute"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_arn_suffix
    TargetGroup  = local.tg_arn_suffix
  }

  alarm_actions = [local.sns_arn]
  ok_actions    = [local.sns_arn]
}

# ── ALB 5XX (load balancer itself) ────────────────────────
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project}-alb-5xx"
  alarm_description   = "ALB-level 5XX errors > 5 in 1 minute"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_arn_suffix
  }

  alarm_actions = [local.sns_arn]
  ok_actions    = [local.sns_arn]
}

# ── Target Response Time (p95) ────────────────────────────
resource "aws_cloudwatch_metric_alarm" "response_time" {
  alarm_name          = "${var.project}-response-time-high"
  alarm_description   = "p95 response time > 5s for 3 consecutive minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  extended_statistic  = "p95"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_arn_suffix
    TargetGroup  = local.tg_arn_suffix
  }

  alarm_actions = [local.sns_arn]
  ok_actions    = [local.sns_arn]
}

# ── Unhealthy Host Count ──────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.project}-unhealthy-hosts"
  alarm_description   = "One or more ECS targets are unhealthy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_arn_suffix
    TargetGroup  = local.tg_arn_suffix
  }

  alarm_actions = [local.sns_arn]
  ok_actions    = [local.sns_arn]
}