output "build_server_ip" {
  value = aws_instance.build.public_ip
}
output "deploy_server_ip" {
    value = aws_instance.deploy.public_ip
}