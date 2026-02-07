provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block              = var.vpc_cidr
  enable_dns_hostnames    = true
  enable_dns_support      = true

  tags = {
    Name                  = "${var.project_name}-vpc"
  }
}
resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id  
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0] 
  map_public_ip_on_launch = true

  tags = {
    Name                 = "${var.project_name}-public-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id                 = var.vpc_id  

  tags = {
    Name                 = "${var.project_name}-igw"
  }
}

# Public Route Table     
resource "aws_route_table" "public" {
  vpc_id                 = var.vpc_id  

  route {
    cidr_block           = var.RT_CIDR_BLOCK
    gateway_id           = var.igw_id  
  }

  tags = {
    Name                 = "${var.project_name}-public-rt"
  }
}
resource "aws_route_table_association" "public" {
   subnet_id             = aws_subnet.public.id
  route_table_id         = aws_route_table.public.id

}
resource "aws_security_group" "web_sg" {
  vpc_id                 = var.vpc_id

  ingress {
    from_port            = 22
    to_port              = 22
    protocol             = "tcp"
    cidr_blocks         = var.MY_IP
  }
}
resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id

dynamic "ingress" {
  for_each = var.ingress_ports
  content {
    from_port   = ingress.value.port
    to_port     = ingress.value.port
    protocol    = ingress.value.protocol
    cidr_blocks = ["147.236.163.3"]
    description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "masters" {
  count         = 3
  ami           = "ami-xxxxxx"
  instance_type = "t3.medium"
  private_ip    = "10.0.1.${10 + count.index}" 

  tags = { Name = "master-${count.index + 1}" }
}
resource "aws_instance" "workers" {
  count         = 2
  ami           = "ami-xxxxxx"
  instance_type = "t3.micro"
  

  tags = { Name = "worker-${count.index + 1}" }
}

resource "aws_instance" "masters" {
  count         = var.master_count
  ami           = var.ami_id
  instance_type = "t3.medium"
  private_ip    = "10.0.1.${10 + count.index}"
  
 
  tags = { Name = "k8s-master-${count.index + 1}" }
}


resource "aws_instance" "workers" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = "t3.micro"
  private_ip    = "10.0.1.${20 + count.index}"
  key_name       =   "aws_key_pair"
  tags = { Name = "k8s-worker-${count.index + 1}" }
}


resource "aws_eip" "master_ips" {
  count    = var.master_count
  instance = aws_instance.masters[count.index].id
  domain   = "vpc"
}

resource "aws_eip" "worker_ips" {
  count    = var.worker_count
  instance = aws_instance.workers[count.index].id
  domain   = "vpc"
}

