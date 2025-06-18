provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_pair" {
  key_name   = "terraform-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content              = tls_private_key.generated_key.private_key_pem
  filename             = "${path.module}/terraform-key.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Permisos inbound/outbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "ec2_user_data" {
  template = file("${path.module}/install_docker_and_run.sh.tpl")

  vars = {
    rds_endpoint = aws_db_instance.postgres.address
    db_name      = var.db_name
    db_user      = var.db_username
    db_password  = var.db_password
  }
}

resource "aws_instance" "api" {
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  key_name                    = aws_key_pair.generated_key_pair.key_name
  associate_public_ip_address = true

  user_data = data.template_file.ec2_user_data.rendered

  tags = {
    Name = "SpringBootDockerAPI"
  }
}
