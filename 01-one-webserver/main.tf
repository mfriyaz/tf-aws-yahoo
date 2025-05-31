
/*
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
  

  tags = {
    Name = "main"
    Environment = "dev"
    Owner = "Riyaz"
    }
  }

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id  
  tags = {
    Name = "main"
    Environment = "dev"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "main"
    Enviromnet = "dev"
  }
  }

  resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-southeast-1b"
  } */

  
# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Create security group allowing SSH and HTTP
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Ubuntu EC2 instance
resource "aws_instance" "ubuntu_instance" {
  ami                    = "ami-0c1907b6d738188e5"  # Ubuntu 22.04 LTS for us-east-1
  instance_type          = "t2.micro"
  key_name               = "terrafrom.pem"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl enable apache2
              systemctl start apache2
              echo "<h1>Ubuntu Web Server Running</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "UbuntuSingleTier"
  }
}
