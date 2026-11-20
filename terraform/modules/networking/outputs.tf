output "my-vpc" {
  value = aws_vpc.my-vpc.id
}

output "public-subnet" {
  value = aws_subnet.public-subnet
}

output "public-subnet-2" {
  value = aws_subnet.public-subnet-2
}