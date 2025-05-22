# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0afc7fe9be84307e4"
  instance_type = "t2.micro"

tags={
	Name = "terraform-example"
    }
}