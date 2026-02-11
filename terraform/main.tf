provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {}

# --- SSH Key Generation (The Fix) ---

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-cluster-key-unique"
  public_key = tls_private_key.pk.public_key_openssh
}


resource "local_file" "ssh_key" {
  content         = tls_private_key.pk.private_key_pem
  filename        = "${path.module}/k8s-key.pem"
  file_permission = "0400"
}

# --- Network ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project_name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project_name}-public-subnet" }
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

# --- Security Groups ---
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # السماح بجميع الاتصالات الداخلية من السيرفر لنفسه
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # السماح بالخروج لأي مكان (للتحميل وتحديث النظام)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Instances ---
resource "aws_instance" "masters" {
  count                  = var.master_count
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  # تأكد أن الـ CIDR الخاص بالـ Subnet يطابق هذا النطاق
  private_ip             = "10.0.1.${10 + count.index}" 
  key_name               = aws_key_pair.k8s_key.key_name
  tags                   = { Name = "k8s-master-${count.index + 1}" }
  
  # اعتمادية لضمان وجود المفتاح والشبكة قبل إنشاء السيرفر
  depends_on = [aws_internet_gateway.main, aws_key_pair.k8s_key]
}

resource "aws_instance" "workers" {
  count                  = var.worker_count
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  private_ip             = "10.0.1.${20 + count.index}"
  key_name               = aws_key_pair.k8s_key.key_name
  source_dest_check      = false
  tags                   = { Name = "k8s-worker-${count.index + 1}" }

  depends_on = [aws_internet_gateway.main, aws_key_pair.k8s_key]
}

# --- Elastic IPs ---
resource "aws_eip" "master_ips" {
  count    = var.master_count
  instance = aws_instance.masters[count.index].id
  domain   = "vpc" # التحديث الجديد يتطلب تحديد domain بدلاً من vpc = true
}

resource "aws_eip" "worker_ips" {
  count    = var.worker_count
  instance = aws_instance.workers[count.index].id
  domain   = "vpc"
}