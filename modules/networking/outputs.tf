output "private_subnet" {
  value = aws_subnet.private_subnet.id
}

output "tags" {
  value = var.tags
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_route_id" {
  value = aws_route_table.private_rt.id
}
