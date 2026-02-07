provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {}

# --- Network ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-public-subnet" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"] 
    }
  }
  ingress { 
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-cluster-key"
  public_key = var.ssh_public_key
}


resource "aws_instance" "masters" {
  count                  = var.master_count
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  private_ip             = "10.0.1.${10 + count.index}"
  key_name               = aws_key_pair.k8s_key.key_name
  tags                   = { Name = "k8s-master-${count.index + 1}" }
}

resource "aws_instance" "workers" {
  count                  = var.worker_count
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  private_ip             = "10.0.1.${20 + count.index}"
  key_name               = aws_key_pair.k8s_key.key_name
  source_dest_check      = false 
  tags                   = { Name = "k8s-worker-${count.index + 1}" }
}

resource "aws_eip" "master_ips" {
  count    = var.master_count
  instance = aws_instance.masters[count.index].id
}

resource "aws_eip" "worker_ips" {
  count    = var.worker_count
  instance = aws_instance.workers[count.index].id
}