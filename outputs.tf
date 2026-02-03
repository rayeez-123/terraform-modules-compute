output "public_instance_ids" {
  value = aws_instance.public-instance[*].id
}

output "private_instance_ids" {
  value = aws_instance.private-instance[*].id
}
