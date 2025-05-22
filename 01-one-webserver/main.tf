# Create a Security Group for an EC2 instance
resource "aws_security_group" "demosg" {
	name = "terraform-example-instance-sg
	
	ingress {
		from_port =8080
		to_port = 8080
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0afc7fe9be84307e4"
  instance_type = "t2.micro"

tags={
	Name = "terraform-example"
    }
}

