
resource "aws_cloudwatch_log_group" "service" {
  name = "/aws/ecs/${var.CLUSTER_NAME}/${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  retention_in_days = 3
}
