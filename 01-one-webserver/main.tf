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
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "main"
    Enviromnet = "dev"
  }
  }