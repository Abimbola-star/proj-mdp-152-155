provider "aws" {
    region = "us-east-1"
} 
resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "k8s_vpc"
  }
}

// Create Subnet A
resource "aws_subnet" "pub_k8s_subnet_a" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub_subnet_a"
    Environment = "k8s"
  }
}

// creating Subnet B
resource "aws_subnet" "pub_k8s_subnet_b" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub_subnet_b"
    Environment = "k8s"
  }
}
// creating internet gateway
resource "aws_internet_gateway" "igw_k8s" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "igw_k8s"
    Environment = "k8s"
  }
}

// creating route table
resource "aws_route_table" "pub_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_k8s.id
  }

  tags = {
    Name = "pub_route_table_a"
    Environment = "k8s"
  }
}

// associating route table with subnet
resource "aws_route_table_association" "pub_rt_assoc_a" {
  subnet_id      = aws_subnet.pub_k8s_subnet_a.id
  route_table_id = aws_route_table.pub_route_table.id
}

resource "aws_route_table_association" "pub_rt_assoc_b" {
  subnet_id      = aws_subnet.pub_k8s_subnet_b.id
  route_table_id = aws_route_table.pub_route_table.id
}

// creating security group
resource "aws_security_group" "sg_k8s" {
  name        = "sg_k8s"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.k8s_vpc.id


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}

resource "aws_s3_bucket" "kops_state_store" {
  bucket = "k8-bucket-abi8971"

  tags = {
    Name        = "KopsStatebucket"
    Environment = "k8s"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.kops_state_store.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.kops_state_store.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.kops_state_store.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_route53_zone" "k8s_zone" {
  name = "aamyresumebucket.click"
}

// ec2 instance for k8s workstation
resource "aws_instance" "k8s_worksstation" {
  ami = "ami-0e58b56aa4d64231b"
  instance_type = "t2.medium"
  key_name = "amazonlinux.pem"
  subnet_id = aws_subnet.pub_k8s_subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg_k8s.id]
  tags = {
    Name = "k8s_worksstation"
  }
}

//ec2 instance for Ansible master
resource "aws_instance" "ansible" {
  ami = "ami-0e58b56aa4d64231b"
  instance_type = "t2.micro"
  key_name = "amazonlinux.pem"
  subnet_id = aws_subnet.pub_k8s_subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg_k8s.id]
  user_data = <<-EOF
  #!/bin/bash
  sudo yum -y update
  # Enable EPEL repository
  sudo amazon-linux-extras install epel
  
  # Install Ansible
  sudo yum install -y ansible
  
  # Verify installation (optional, logs to /var/log/user-data.log)
  ansible --version >> /var/log/user-data.log 2>&1
  EOF

  tags = {
    Name = "ansible"
  }
}