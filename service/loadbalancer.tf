
resource "aws_alb" "service" {
  name = "${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  internal = false
  subnets = ["${var.LB_SUBNETS}"]

  tags {
    Environment = "${var.ENVIRONMENT}"
  }

  security_groups = ["${aws_security_group.service.id}"]
}

resource "aws_alb_target_group" "service" {
  name = "${var.SERVICE_NAME}-${var.ENVIRONMENT}"
  port = 8000
  protocol = "HTTP"
  vpc_id = "${var.VPC_ID}"
  health_check = {
    path = "/healthcheck"
  }
}

resource "aws_alb_listener" "service" {
  load_balancer_arn = "${aws_alb.service.arn}"
  port = 80
  protocol = "HTTP"
  depends_on = ["aws_alb_target_group.service"]
  default_action {
    target_group_arn = "${aws_alb_target_group.service.arn}"
    type = "forward"
  }
}


resource "aws_security_group" "service" {
  name = "${var.SERVICE_NAME}_${var.ENVIRONMENT}_ALB"
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
