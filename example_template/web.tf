provider "aws" {
  region = "${var.region}"
}

resource "aws_elb" "web_lb" {
  name             = "web-elb"
  internal         = true
  security_groups  = ["${aws_security_group.web_server.id}"]
  subnets  = [
    "${element(split(\",\", var.private_subnets), 0)}",
    "${element(split(\",\", var.private_subnets), 1)}",
    "${element(split(\",\", var.private_subnets), 2)}"
  ]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }
}

resource "aws_security_group" "web_server" {
  name        = "web_server"
  description = "Used for all web servers"
  vpc_id      = "${var.vpc_id}"
  ingress { #SSH invar
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "10.0.0.0/8" ]
  }
  ingress { #SSH in from the VPC
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "10.0.0.0/8" ]
  }
}

resource "aws_launch_configuration" "launch_config" {
  image_id        = "${var.ami}"
  instance_type   = "${var.instance_size}"
  security_groups = ["${aws_security_group.web_server.id}"]
  key_name        = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  availability_zones        = [
    "${element(split(\",\", var.availability_zones), 0)}",
    "${element(split(\",\", var.availability_zones), 1)}",
    "${element(split(\",\", var.availability_zones), 2)}"
  ]
  name                      = "web_${var.ami}"
  max_size                  = "${var.count}"
  min_size                  = "${var.count}"
  health_check_grace_period = 300
  load_balancers            = ["${aws_elb.web_lb.name}"]
  health_check_type         = "EC2"
  desired_capacity          = "${var.count}"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.launch_config.name}"
  vpc_zone_identifier       = [
    "${element(split(\",\", var.private_subnets), 0)}",
    "${element(split(\",\", var.private_subnets), 1)}",
    "${element(split(\",\", var.private_subnets), 2)}"
  ]
}
