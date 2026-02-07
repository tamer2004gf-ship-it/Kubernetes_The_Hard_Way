variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "tf-example"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "igw_id" {
  description = "Internet Gateway ID"
  type        = string
}
variable "RT_CIDR_BLOCK" {
  description = "CIDR block for route table"
  type        = string
  default     = "0.0.0/0"
  
}
variable "ingress_ports" {
  type = list(object({
    port        = number
    protocol    = string
    description = string
  }))
  default = [
    { port = 22,   protocol = "tcp", description = "SSH" },
    { port = 6443,   protocol = "tcp", description = "Kubernetes API Server" },
    
  ]
}
variable "MY_IP" {
  description = "List of CIDR blocks allowed for SSH "
  type        = list(string)
  default     = ["147.236.163.136/32"]
  
}
variable "ami_id" {
  default = "ami-0191d47ba10441f0b"
}

variable "master_count" {
  default = 3
}

variable "worker_count" {
  default = 2
}
