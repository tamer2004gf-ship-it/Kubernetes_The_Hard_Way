output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}
output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway (alias)"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}
variable "nat_gateway_id" {
  description = "NAT Gateway ID"
  type        = string
}
output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web_sg.id
}

output "web_sg_id" {
  description = "ID of the web security group (alias)"
  value       = aws_security_group.web_sg.id
}
output "master_public_ips" {
  value = { for k, v in aws_eip.master_ips : "master-${k+1}" => v.public_ip }
}

output "worker_public_ips" {
  value = { for k, v in aws_eip.worker_ips : "worker-${k+1}" => v.public_ip }
}
