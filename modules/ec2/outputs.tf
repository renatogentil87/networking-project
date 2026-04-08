output "instance_id" {
  value = aws_instance.this.id
}

output "security_group_id" {
  value = aws_security_group.private_sg.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}
