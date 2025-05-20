// creating custom vpc
resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "devops_vpc"
  }

}
// creating custom subnet
resource "aws_subnet" "pub_devops_subnet_a" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_a"
    Environment = "devops"
  }
}

// creating custom subnet
resource "aws_subnet" "pub_devops_subnet_b" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_b"
    Environment = "devops"
  }
}

// creating internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "igw"
    Environment = "devops"
  }
}

// creating route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table_a"
    Environment = "devops"
  }
}

// associating route table with subnet
resource "aws_route_table_association" "public_rt_assoc_a" {
  subnet_id      = aws_subnet.pub_devops_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rt_assoc_b" {
  subnet_id      = aws_subnet.pub_devops_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}