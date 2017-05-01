resource "aws_ecs_service" "service" {
  name = "${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  cluster = "arn:aws:ecs:eu-west-1:${var.ACCOUNT_NUMBER}:cluster/${var.CLUSTER_NAME}"
  task_definition = "${aws_ecs_task_definition.api.arn}"
  iam_role = "${aws_iam_role.ecs-role.arn}"
  depends_on = [
    "aws_iam_role_policy.ecs-policy"
  ]
  desired_count = 1

  placement_strategy {
    type = "binpack"
    field = "cpu"
  }

  placement_constraints {
    type = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b, eu-west-1c]"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-service.arn}"
    container_name = "${var.SERVICE_NAME}-${var.ENVIRONMENT}"
    container_port = 8000
  }
}

resource "aws_ecs_task_definition" "api" {
  family = "${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  container_definitions = <<EOF
    [
      {
        "name": "${var.SERVICE_NAME}-${var.ENVIRONMENT}",
        "image": "crccheck/hello-world",
        "portMappings": [
          {
            "ContainerPort": 8000,
            "protocol": "tcp"
          }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.service.name}",
                "awslogs-region": "${var.REGION}",
                "awslogs-stream-prefix": "${var.SERVICE_NAME}-${var.ENVIRONMENT}"
            }
        },
        "memory": 256,
        "name": "${var.SERVICE_NAME}-${var.ENVIRONMENT}",
        "essential" : true
      }
    ]
    EOF
}

resource "aws_iam_role" "ecs-role" {
  name = "${var.SERVICE_NAME}_${var.ENVIRONMENT}_ecs_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs-policy" {
  name = "${var.SERVICE_NAME}_${var.ENVIRONMENT}_ecs_iam_policy"
  role = "${aws_iam_role.ecs-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
