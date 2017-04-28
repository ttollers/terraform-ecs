resource "aws_cloudwatch_metric_alarm" "scale-up" {
  alarm_name = "${var.application_name}-scale-up-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  statistic = "Average"
  threshold = "60"
  unit = "Percent"

  dimensions {
    ClusterName = "${var.CLUSTER_NAME}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_description = "This metric monitor ec2 cpu utilization"
  alarm_actions = [
    "${aws_appautoscaling_policy.scale-up.arn}"
  ]
}

resource "aws_appautoscaling_target" "scale-up" {
  max_capacity = 10
  min_capacity = 1
  resource_id = "service/${var.CLUSTER_NAME}/${var.application_name}-${var.environment}"
  role_arn = "arn:aws:iam::247237293916:role/ecsAutoscaleRole"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "scale-up" {
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  metric_aggregation_type = "Maximum"
  name = "${var.application_name}-scaling-${var.environment}"
  resource_id = "service/${var.CLUSTER_NAME}/${var.application_name}-${var.environment}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment = 1
  }

  depends_on = [
    "aws_appautoscaling_target.scale-up"
  ]
}
