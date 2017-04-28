resource "aws_ecs_service" "service" {
  name = "${var.application_name}-${var.environment}"
  cluster = "arn:aws:ecs:eu-west-1:247237293916:cluster/${var.CLUSTER_NAME}"
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
    container_name = "${var.application_name}-${var.environment}"
    container_port = 8000
  }
}

resource "aws_ecs_task_definition" "api" {
  family = "${var.application_name}-${var.environment}"
  container_definitions = <<EOF
    [
      {
        "name": "${var.application_name}-${var.environment}",
        "image": "crccheck/hello-world",
        "portMappings": [
          {
            "ContainerPort": 8000,
            "protocol": "tcp"
          }
        ],
        "memory": 256,
        "name": "${var.application_name}-${var.environment}",
        "essential" : true
      }
    ]
    EOF
}

resource "aws_alb" "ecs-service" {
  name = "${var.application_name}-${var.environment}"
  internal = false
  subnets = [
    "subnet-ecefc79a",
    "subnet-a481b5c0",
    "subnet-a481b5c0"]

  tags {
    Environment = "${var.environment}"
  }

  security_groups = ["${aws_security_group.service.id}"]
}

resource "aws_alb_target_group" "ecs-service" {
  name = "${var.application_name}-${var.environment}"
  port = 8000
  protocol = "HTTP"
  vpc_id = "vpc-871d38e3"
  health_check = {
    path = "/healthcheck"
  }
}

resource "aws_alb_listener" "ecs-service" {
  load_balancer_arn = "${aws_alb.ecs-service.arn}"
  port = 80
  protocol = "HTTP"
  depends_on = ["aws_alb_target_group.ecs-service"]
  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-service.arn}"
    type = "forward"
  }
}

resource "aws_iam_role" "ecs-role" {
  name = "${var.application_name}_${var.environment}_ecs_iam_role"
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
  name = "${var.application_name}_${var.environment}_ecs_iam_policy"
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

resource "aws_security_group" "service" {
  name = "${var.application_name}_${var.environment}_ALB_sec_group"
  description = "ECS ALB Security Group"
  vpc_id = "vpc-871d38e3"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
