resource "aws_cloudwatch_metric_alarm" "scale-down" {
  alarm_name = "${var.SERVICE_NAME}-scale-down-${var.ENVIRONMENT}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  statistic = "Average"
  threshold = "30"
  unit = "Percent"

  dimensions {
    ClusterName = "${var.CLUSTER_NAME}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_description = "This metric monitor ec2 cpu utilization"
  alarm_actions = [
    "${aws_appautoscaling_policy.scale-down.arn}"
  ]
}

resource "aws_appautoscaling_target" "scale-down" {
  max_capacity = 10
  min_capacity = 1
  resource_id = "service/${var.CLUSTER_NAME}/${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  role_arn = "arn:aws:iam::${var.ACCOUNT_NUMBER}:role/ecsAutoscaleRole"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "scale-down" {
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  metric_aggregation_type = "Maximum"
  name = "${var.SERVICE_NAME}-scaling-${var.ENVIRONMENT}"
  resource_id = "service/${var.CLUSTER_NAME}/${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment = -1
  }

  depends_on = [
    "aws_appautoscaling_target.scale-down"
  ]
}

