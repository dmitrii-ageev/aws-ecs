# VPC
resource "aws_vpc" "orion_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name      = "Orion VPC",
    Temporary = "Yes"
  }
}

# Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.orion_vpc.id
}

# Subnet
resource "aws_subnet" "orion_sn" {
  vpc_id     = aws_vpc.orion_vpc.id
  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name      = "Containers subnet",
    Temporary = "Yes"
  }
}

# Route table

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.orion_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate route table with the subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.orion_sn.id
  route_table_id = aws_route_table.rt.id
}

