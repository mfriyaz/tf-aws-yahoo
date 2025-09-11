
# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Create security group allowing SSH, HTTP, and 8080
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH, HTTP and 8080 inbound traffic"
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
    description = "App Port 8080"
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

# IAM role for SSM
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

# Launch Linux EC2 instance
resource "aws_instance" "ubuntu_instance" {
  ami                         = "ami-0933f1385008d33c4"  # Ubuntu 22.04 LTS (ap-southeast-1)
  instance_type               = "t2.micro"
  key_name                    = "terrafrom"
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "UbuntuSingleTireForOnlineApp"
  }
}

# CloudWatch alarm for Auto Recovery
resource "aws_cloudwatch_metric_alarm" "ec2_auto_recovery" {
  alarm_name          = "ec2-auto-recovery-${aws_instance.ubuntu_instance.id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Recover EC2 instance when system status check fails"
  dimensions = {
    InstanceId = aws_instance.ubuntu_instance.id
  }

  alarm_actions = [
    "arn:aws:automate:ap-southeast-1:ec2:recover"
  ]
}
