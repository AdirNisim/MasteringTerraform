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

  tags = {
    Name = "my-ubuntu"
  }
}