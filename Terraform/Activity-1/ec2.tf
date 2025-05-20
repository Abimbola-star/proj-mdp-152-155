// ec2 instance for building
resource "aws_instance" "build" {
  ami = "ami-0e58b56aa4d64231b"
  instance_type = "t2.micro"
  key_name = "amazonlinux.pem"
  subnet_id = aws_subnet.pub_devops_subnet_a.id
  vpc_security_group_ids = [aws_security_group.build_security_group.id]
  user_data = file("build.sh")
  tags = {
    Name = "build"
  }
}

//ec2 instance for deploying
resource "aws_instance" "deploy" {
  ami = "ami-0e58b56aa4d64231b"
  instance_type = "t2.micro"
  key_name = "amazonlinux.pem"
  subnet_id = aws_subnet.pub_devops_subnet_b.id
  vpc_security_group_ids = [aws_security_group.deploy_security_group.id]
  user_data = file("deploy.sh")
  tags = {
    Name = "deploy"
  }
}

