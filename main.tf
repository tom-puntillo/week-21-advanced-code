# Create an AWS security group for the Auto Scaling Group instances
resource "aws_security_group" "asg-sg" {
  name = "week-21-asg-sg"

  # Ingress rule to allow SSH access from the specified host IP
  ingress {
    cidr_blocks = [
      var.host_ip
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  # Ingress rule to allow HTTP access from anywhere
  ingress {
    security_groups = [aws_security_group.alb_sg.id]
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
  }

  # Egress rule to allow all traffic from instances to the Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name = "week_21_alb_sg"

  # Ingress rule to allow HTTP access from anywhere
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  # Egress rule to allow all traffic from instances to the Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create an AWS key pair for SSH access to instances
resource "aws_key_pair" "key_pair" {
  key_name   = "week-21-kp"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create an AWS launch template for the Auto Scaling Group instances
resource "aws_launch_template" "my-lt" {
  name = "week-21-lt"

  image_id = "ami-09538990a0c4fe9be"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  # Use the previously created AWS key pair for SSH access
  key_name = aws_key_pair.key_pair.key_name

  # Attach the previously created security group to the instances
  security_group_names = ["week-21-asg-sg"]

  # Provide user data from a base64-encoded file for instance customization
  user_data = var.user_data
}

# Create an AWS Auto Scaling Group with instances using the launch template
resource "aws_autoscaling_group" "week-21-asg" {
  name               = "week-21-asg"
  availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 3
  max_size           = 5
  min_size           = 2
  target_group_arns  = [aws_lb_target_group.alb_tg.arn]

  # Use the previously created launch template for instance configuration
  launch_template {
    id      = aws_launch_template.my-lt.id
    version = "$Latest" # Use the latest version of the launch template
  }
}

resource "aws_lb" "apache_lb" {
  name               = "week-21-apache-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "week-21-alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.apache_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  condition {
    query_string {
      key   = "health"
      value = "check"
    }
  }
}

resource "aws_autoscaling_attachment" "alb_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.week-21-asg.name
  lb_target_group_arn    = aws_lb_target_group.alb_tg.arn
}