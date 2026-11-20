# Create a VPC
# Region is only specified for vpc and the eip
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc-cidr
  region     = var.region
}

# Create Subnets
# Private subnet for the app
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  availability_zone     = var.az-1
  cidr_block = var.priv-sub-cidr
  
  depends_on = [ aws_vpc.my-vpc ]

}

# Public subnets
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  availability_zone = var.az-1
  cidr_block = var.pub-sub-cidr

  depends_on = [ aws_vpc.my-vpc ]

}
resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.my-vpc.id
  availability_zone =  var.az-2
  cidr_block = var.pub-sub-cidr-2

  depends_on = [ aws_vpc.my-vpc ]

}


# Creating an internet Gateway for the private app
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-igw"
  }

  depends_on = [ aws_vpc.my-vpc ]
}

# Creating an elastic IP for nat gateway 
resource "aws_eip" "nat-eip" {
  region = var.region
}

# Creating the nat gateway for private application
# Must be in the public subnet
resource "aws_nat_gateway" "my-nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "my-nat-gateway"
  }


  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my-igw]
}



# Creating the route tables for each subnet

# Private subnet route table

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-nat-gateway.id
  }

}

resource "aws_route_table_association" "private-route-assoc" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}



# Route table for the public subnets
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

# Attach it to public subnet 1
resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# Attach it to public subnet 2
resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}