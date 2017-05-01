resource "aws_ecs_cluster" "cluster" {
  name = "${var.CLUSTER_NAME}-${var.ENVIRONMENT}"
}

resource "aws_autoscaling_group" "cluster" {
  name = "${var.CLUSTER_NAME}-${var.ENVIRONMENT}-asg-${aws_launch_configuration.cluster.name}"
  max_size = 1
  min_size = 1
  health_check_grace_period = 120
  health_check_type = "ELB"
  desired_capacity = 1
  force_delete = true
  launch_configuration = "${aws_launch_configuration.cluster.name}"
  vpc_zone_identifier = [
    "subnet-ecefc79a",
    "subnet-ecefc79a",
    "subnet-ecefc79a"]
  metrics_granularity = "1Minute"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_placement_group" "cluster" {
  name = "${var.CLUSTER_NAME}-${var.ENVIRONMENT}"
  strategy = "cluster"
}

resource "aws_launch_configuration" "cluster" {
  name_prefix = "${var.CLUSTER_NAME}-${var.ENVIRONMENT}"
  image_id = "ami-95f8d2f3"
  instance_type = "t2.micro"
  key_name = "${var.SSH_KEY_NAME}"
  security_groups = [
    "${aws_security_group.cluster.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.cluster.arn}"
  user_data = "${file("user-data.txt")}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "cluster" {
  name = "${var.CLUSTER_NAME}_${var.ENVIRONMENT}_iam_profile"
  roles = [
    "${aws_iam_role.cluster.name}"]
}

resource "aws_iam_role" "cluster" {
  name = "${var.CLUSTER_NAME}_${var.ENVIRONMENT}_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ecs.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cluster" {
  name = "${var.CLUSTER_NAME}_${var.ENVIRONMENT}_iam_policy"
  role = "${aws_iam_role.cluster.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecs:*",
        "s3:*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_security_group" "cluster" {
  name = "${var.CLUSTER_NAME}_${var.ENVIRONMENT}_sec_group"
  description = "Lamda Security Group"
  vpc_id = "${var.VPC_ID}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}
