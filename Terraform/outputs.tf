
### outputs needed to create self-hosted aws ec2 runner
# private data subnet az1 id
output "private_data_subnet_az1_id" {
  value = aws_subnet.private_data_subnet_az1.id
}

