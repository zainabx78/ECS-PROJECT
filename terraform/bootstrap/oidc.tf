# This code lets GitHub Actions log in to AWS account without storing any passwords or keys.
# It's the security setup that allows pipeline to push images and run Terraform.


# Giving a nickname to GitHub's address to use multiple times underneath.
locals {
  gh = "token.actions.githubusercontent.com"
}


# Step 1 - establishing trust between AWS and GitHub
# It registers GitHub as a trusted ID card issuer in my account
resource "aws_iam_openid_connect_provider" "gh" {
  url            = "https://${local.gh}"
  client_id_list = ["sts.amazonaws.com"]
}


# Step 2 - create an IAM role for GitHub Actions
# Includes the rules for who is allowed to use it
resource "aws_iam_role" "github" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRoleWithWebIdentity"
        Principal = { Federated = aws_iam_openid_connect_provider.gh.arn }
        Condition = {
          # Check the identity card was made for AWS
          StringEquals = { "${local.gh}:aud" = "sts.amazonaws.com" }

          # Who may use the role: only my repo, on the main branch
          StringLike = { "${local.gh}:sub" = "repo:zainabx78/ECS-PROJECT:ref:refs/heads/main" }
        }
      }
    ]
  })
}


# Step 3 - granting ECR permissions to push images
# What the GitHub role is allowed to do: push images to my ECR repo
resource "aws_iam_role_policy" "ecr_push" {
  name = "github-ecr-push"
  role = aws_iam_role.github.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Logging in to ECR (AWS only allows this one for "everything")
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        # Uploading the image, but only to my repo
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = aws_ecr_repository.my-ecr-repo.arn
      }
    ]
  })
}

# Step 4 - a second role for the Terraform pipelines (deploy and destroy)
# Same trust rules as the GitHub role: only my repo, on the main branch
resource "aws_iam_role" "terraform" {
  name = "github-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRoleWithWebIdentity"
        Principal = { Federated = aws_iam_openid_connect_provider.gh.arn }
        Condition = {
          StringEquals = { "${local.gh}:aud" = "sts.amazonaws.com" }
          StringLike   = { "${local.gh}:sub" = "repo:zainabx78/ECS-PROJECT:*" }
        }
      }
    ]
  })
}

# What it's allowed to do: everything (Terraform creates many different AWS services)
resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}