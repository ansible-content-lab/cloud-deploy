provider "aws" {
  region     = var.ec2_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "${var.ec2_prefix}-vpc" {
  cidr_block = "192.168.0.0/24"

  tags = {
    provisioner = "mford"
    application  = var.application
    demo = "appdeployment"
  }
}


resource "aws_security_group" "${var.ec2_prefix}-sg" {
  name        = "${var.ec2_prefix}-sg"
  vpc_id      = aws_vpc.${var.ec2_prefix}-vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Hashicorp Vault"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    provisioner = "mford"
    Name = "${var.ec2_prefix}-sg"
    application: var.application
    demo: "appdeployment"
  }
}

resource "aws_subnet" "${var.ec2_prefix}-subnet" {
  vpc_id            = aws_vpc.${var.ec2_prefix}-vpc.id
  cidr_block        = "192.168.0.0/28"
  map_public_ip_on_launch = "true"

  tags = {
    provisioner = "mford"
    application = var.application
    demo = "appdeployment"
  }
}

resource "aws_internet_gateway" "${var.ec2_prefix}-igw" {
  vpc_id = aws_vpc.${var.ec2_prefix}-vpc.id

  tags = {
    provisioner = "mford"
    application = var.application
    demo = "appdeployment"
  }
}

resource "aws_default_route_table" "${var.ec2_prefix}-route-table" {
  default_route_table_id = aws_vpc.${var.ec2_prefix}-vpc.default_route_table_id
  route {
    cidr_block                = "0.0.0.0/0"
    gateway_id                = aws_internet_gateway.${var.ec2_prefix}-igw.id

  }

  tags = {
    provisioner = "mford"
    application = var.application
    demo = "appdeployment"
  }
}

resource "tls_private_key" "${var.ec2_prefix}-tls-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "${var.ec2_prefix}-key" {
  key_name   = "${var.ec2_prefix}-key"
  public_key = tls_private_key.${var.ec2_prefix}-tls-private-key.public_key_openssh
}

resource "aws_instance" "cloud-deploy-webservers" {
  count         = var.num_instances
  ami           = var.ec2_image_id
  instance_type = var.machine_type
  key_name      = aws_key_pair.${var.ec2_prefix}-key.key_name
  subnet_id     = aws_subnet.${var.ec2_prefix}-subnet.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.${var.ec2_prefix}-sg.id]
  tags = {
    Name = "${var.ec2_prefix}-webserver-${count.index + 1}"
    provisioner = "mford"
    application = var.application
    demo = "appdeployment"
    group = "rhel"
    ec2_prefix = var.ec2_prefix
    cloud_provider = "aws"
  }
}

resource "aws_instance" "cloud-deploy-secrets-engine" {
  count         = 1
  ami           = var.ec2_image_id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.${var.ec2_prefix}-key.key_name
  subnet_id     = aws_subnet.${var.ec2_prefix}-subnet.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.${var.ec2_prefix}-sg.id]
  tags = {
    provisioner = "mford"
    application = var.application
    Name = "secret-engine-server"
    demo = "appdeployment"
    group = "webserver"
    ec2_prefix = ${var.ec2_prefix}
    cloud_provider = "aws"
  }
}

resource "local_file" "private_key" {
    content          = tls_private_key.${var.ec2_prefix}-tls-private-key.private_key_pem
    filename         = "/tmp/${var.ec2_prefix}-key-private.pem"
    file_permission  = "0600"
}

resource "local_file" "public_key" {
    content          = tls_private_key.${var.ec2_prefix}-tls-private-key.public_key_openssh
    filename         = "/tmp/${var.ec2_prefix}-key.pub"
    file_permission  = "0600"
}
