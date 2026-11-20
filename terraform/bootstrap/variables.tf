# Used for the remote S3 state file in bootstrap
variable "bucket_name" {
  default = "zainab-terraform-state-123456"
}

variable "region" {
  default = "eu-west-1"
}
