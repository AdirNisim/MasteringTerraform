provider "aws" {
  region = "us-east-2"
}

/*
resource "aws_instance" "example" {
  ami = "ami-0a695f0d95cefc163" // Amazon Image
  // region-> EC2 -> Launch instance-> choose op, Select ami id 
  // ami will be diffrent in other region
  instance_type = "t3.micro"
  // type of instance memory cpu 
  // documentaion resource:aws_instance for more properties

  // Linking security group with instance below (security group created below)
  vpc_security_group_ids = [aws_security_group.instance.id]

  // user data running script at the time of instance launch
  // EOF lets you to write multi line string
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  user_data_replace_on_change = true
  // to replace the instance if user data is changed

  tags = {
    Name = "my-ubuntu"
  }
}
*/


resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-0a695f0d95cefc163"
  instance_type = "t3.micro"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  )

  vpc_security_group_ids = [aws_security_group.instance.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "my-ubuntu"
    }
  }
}


resource "aws_security_group" "instance" {
  name = "web"

  ingress {
    from_port = var.server_port
    to_port   = var.server_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  vpc_zone_identifier = data.aws_subnets.default.ids
  min_size            = 2
  max_size            = 3

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "my-ubuntu"
    propagate_at_launch = true
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


data "aws_vpc" "default" {
  default = true
}

// Load balancer ALB creation 

resource "aws_lb" "example" {
  name = "web"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}


// create a load balancer listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port              = 80
    protocol = "HTTP"

      default_action {
          type = "fixed-response"

            fixed_response {
              content_type = "text/plain"
              message_body = "404: page not found"
              status_code  = "404"
            }
      }
}

  resource "aws_security_group" "alb" {
      name = "web-alb"

      ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }


      egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  }

resource "aws_lb_target_group" "asg" {
  name     = "web-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}