# Create VPC 1
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC1"
  }
}

# Create Subnet in VPC 1
resource "aws_subnet" "vpc1_subnet" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "VPC1-Subnet"
  }
}

# Create Security Group for VPC 1
resource "aws_security_group" "vpc1_sg" {
  vpc_id = aws_vpc.vpc1.id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC1-SG"
  }
}

# Create EC2 Instance in VPC 1
resource "aws_instance" "vpc1_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your desired AMI
  instance_type = "t2.micro"               # Replace with your desired instance type
  subnet_id     = aws_subnet.vpc1_subnet.id
  security_groups = [aws_security_group.vpc1_sg.name]

  tags = {
    Name = "VPC1-EC2"
  }
}

# Create VPC 2
resource "aws_vpc" "vpc2" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "VPC2"
  }
}

# Create Subnet in VPC 2
resource "aws_subnet" "vpc2_subnet" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "VPC2-Subnet"
  }
}

# Create Security Group for Normal EC2 Instance in VPC 2
resource "aws_security_group" "vpc2_sg_normal" {
  vpc_id = aws_vpc.vpc2.id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC2-SG-Normal"
  }
}

# Create Security Group for GPU EC2 Instance in VPC 2
resource "aws_security_group" "vpc2_sg_gpu" {
  vpc_id = aws_vpc.vpc2.id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic from VPC 1 EC2 instance
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.vpc1_subnet.cidr_block]
  }

  # Allow traffic from VPC 2 Normal EC2 instance
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.vpc2_subnet.cidr_block]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC2-SG-GPU"
  }
}

# Create Normal EC2 Instance in VPC 2
resource "aws_instance" "vpc2_instance_normal" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your desired AMI
  instance_type = "t2.micro"               # Replace with your desired instance type
  subnet_id     = aws_subnet.vpc2_subnet.id
  security_groups = [aws_security_group.vpc2_sg_normal.name]

  tags = {
    Name = "VPC2-EC2-Normal"
  }
}

# Create GPU-enabled EC2 Instance in VPC 2
resource "aws_instance" "vpc2_instance_gpu" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your desired AMI
  instance_type = "p2.xlarge"              # Replace with your desired GPU instance type
  subnet_id     = aws_subnet.vpc2_subnet.id
  security_groups = [aws_security_group.vpc2_sg_gpu.name]

  tags = {
    Name = "VPC2-EC2-GPU"
  }
}
