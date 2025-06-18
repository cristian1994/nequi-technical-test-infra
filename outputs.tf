output "ec2_public_ip" {
  value = aws_instance.api.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "private_key_path" {
  value = local_file.private_key_pem.filename
}
