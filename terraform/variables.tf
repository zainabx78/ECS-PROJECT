variable "region" {
  default = "eu-west-1"
  type    = string
}

# ALB Needs 2 AZ's - each public subnet in a different az.
variable "az-1" {
  default = "eu-west-1a"
  type    = string
}

variable "az-2" {
  default = "eu-west-1b"
  type    = string
}


# VPC CIDR block
# covers 10.0.0.0 all the way to 10.0.255.255
variable "vpc-cidr" {
  default = "10.0.0.0/16"
  type    = string
}

# Private subnet CIDR block
variable "private-subnet-cidr" {
  default = "10.0.0.0/26"
  type    = string
}


variable "public-subnet-cidr-1" {
  default = "10.0.1.0/26"
  type    = string
}

variable "public-subnet-cidr-2" {
  default = "10.0.2.0/26"
  type    = string
}

# Set this variable here but defined in terraform.tfvars
variable "app_password" {
  type      = string
  sensitive = true
}

variable "image_tag" {
  type = string
}