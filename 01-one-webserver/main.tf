
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
   ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
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
  key_name               = "terrafrom"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl enable apache2
              systemctl start apache2
              echo "<h1>Ubuntu Web Server Running</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "UbuntuSingleTier01"
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "EC2SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "EC2SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}
