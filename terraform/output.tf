output "master_public_ips" {
  description = "Public IPs of the master nodes"
  value = { 
    for k, v in aws_eip.master_ips : "master-${k+1}" => v.public_ip 
  }
}

output "worker_public_ips" {
  description = "Public IPs of the worker nodes"
  value = { 
    for k, v in aws_eip.worker_ips : "worker-${k+1}" => v.public_ip 
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.web_sg.id
}