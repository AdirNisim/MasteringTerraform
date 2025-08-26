provider "aws" {
  region = "us-east-2"
}

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
              nohup busybox httpd -f -p 8080 &
              EOF

  user_data_replace_on_change = true
  // to replace the instance if user data is changed

  tags = {
    Name = "my-ubuntu"
  }
}

resource "aws_security_group" "instance" {
  name = "web"

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}