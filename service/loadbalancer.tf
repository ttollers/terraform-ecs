
resource "aws_alb" "ecs-service" {
  name = "${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  internal = false
  subnets = [
    "subnet-ecefc79a",
    "subnet-a481b5c0",
    "subnet-a481b5c0"
  ]

  tags {
    Environment = "${var.ENVIRONMENT}"
  }

  security_groups = ["${aws_security_group.service.id}"]
}

resource "aws_alb_target_group" "ecs-service" {
  name = "${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  port = 8000
  protocol = "HTTP"
  vpc_id = "${var.VPC_ID}"
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


resource "aws_security_group" "service" {
  name = "${var.SERVICE_NAME}_${var.ENVIRONMENT}_ALB_sec_group"
  description = "ECS ALB Security Group"
  vpc_id = "${var.VPC_ID}"

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
