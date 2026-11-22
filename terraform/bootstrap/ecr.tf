

# Creating the ECR repo as part of the bootstrap folder so the CICD pipeline can use it before running terraform apply for the main infra.

# Private ECR repository for the docker image
resource "aws_ecr_repository" "my-ecr-repo" {
  name         = "razzia-app"
  force_delete = true # lets terraform destroy delete it even with an image inside
}
