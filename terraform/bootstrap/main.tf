# Needs it's own terraform env so it can be ran before the actual infrastructure. 
provider "aws" {
  region = var.region
}

# The bucket that stores state
resource "aws_s3_bucket" "state" {
  bucket = var.bucket_name
  force_destroy = true
}

# Keeps old versions of the state file
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Stops the bucket ever being made public
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Writes the backend details into the NGINX project
resource "local_file" "backend_config" {
  filename = "${path.module}/../backend.hcl" # backend.hcl file gets created where the main terraform infra is. 
  content  = <<-EOT
    bucket       = "${aws_s3_bucket.state.bucket}"
    key          = "ecsproject/terraform.tfstate"
    region       = "${var.region}"
    use_lockfile = true
  EOT
}
