variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "k8s-hard-way"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID"
  type        = string
  default     = "ami-0191d47ba10441f0b"
}

variable "master_count" {
  description = "Number of master nodes"
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "ssh_public_key" {
  description = "Public key for EC2 instances"
  type        = string
}

variable "RT_CIDR_BLOCK" {
  description = "CIDR block for route table"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ingress_ports" {
  type = list(object({
    port        = number
    protocol    = string
    description = string
  }))
  default = [
    { 
      port        = 22, 
      protocol    = "tcp", 
      description = "SSH" 
    },
    { 
      port        = 6443, 
      protocol    = "tcp", 
      description = "Kubernetes API Server" 
    }
  ]
}