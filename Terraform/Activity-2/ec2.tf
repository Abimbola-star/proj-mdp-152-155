// ec2 instance for building
resource "aws_instance" "docker" {
  ami = "ami-0e58b56aa4d64231b"
  instance_type = "t2.medium"
  key_name = "amazonlinux.pem"
  subnet_id = aws_subnet.pub_devops_subnet_a.id
  vpc_security_group_ids = [aws_security_group.docker_security_group.id]
  user_data = file("docker.sh")
  tags = {
    Name = "docker"
  }
}



