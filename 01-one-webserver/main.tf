# Create a Security Group for an EC2 instance
resource "aws_security_group" "demosg" {
	name = "terraform-example-instance-sg"
	vpc_id = data.aws_vpc.default.id
	ingress {
		from_port =22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0afc7fe9be84307e4"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.demosg.id ]

tags={
	Name = "terraform-example"
    }
}

data "aws_vpc" "default" {
default = true
}