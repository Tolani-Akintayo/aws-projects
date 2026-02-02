# Elastic IP for NAT gateway
resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-eip1"
  }
}

# NAT gateway for private subnet internet access
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet_az2.id

  tags = {
    Name = "${var.environment}-natgw-az1"
  }

  # Ensure that NAT gateway is created after the internet gateway
  depends_on = [aws_internet_gateway.internet_gateway]

}

# Private route table - routes traffic through NAT gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id
  }

  tags = {
    Name = "${var.environment}-rtb-private"
  }

}

# Associate private subnets with private route table  

resource "aws_route_table_association" "private_app_subnet_az1_association" {
  subnet_id      = aws_subnet.private_app_subnet_az1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_app_subnet_az2_association" {
  subnet_id      = aws_subnet.private_app_subnet_az2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_data_subnet_az1_association" {
  subnet_id      = aws_subnet.private_data_subnet_az1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_data_subnet_az2_association" {
  subnet_id      = aws_subnet.private_data_subnet_az2.id
  route_table_id = aws_route_table.private_route_table.id
}
