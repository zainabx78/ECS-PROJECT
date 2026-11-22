
# # Private ECR repository for the docker image - built in bootstrap folder for CICD pipeline part
# resource "aws_ecr_repository" "my-ecr-repo" {
#   name         = "razzia-app"
#   force_delete = true   # lets terraform destroy delete it even with an image inside
# }

# Creating the ECS cluster 
resource "aws_ecs_cluster" "my-ecs-cluster" {
  name = "razzia-app-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Role that lets ECS pull the image from ECR and write logs
resource "aws_iam_role" "ecs-task-execution-role" {
  name = "razzia-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Lets ECS read the app password from Secrets Manager
resource "aws_iam_role_policy" "ecs-secrets-policy" {
  name = "razzia-secrets-access"
  role = aws_iam_role.ecs-task-execution-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.app-password.arn
      }
    ]
  })
}

# Creating the secret in Secrets Manager - empty safe
resource "aws_secretsmanager_secret" "app-password" {
  name                    = "razzia-app-password"
  recovery_window_in_days = 0
}


# Secret is defined as a variable in root variables file.
# It's actually referenced in the terraform.tfvars file.
# This puts the password in the safe
resource "aws_secretsmanager_secret_version" "app-password-value" {
  secret_id     = aws_secretsmanager_secret.app-password.id
  secret_string = var.app_password
}

data "aws_ecr_repository" "my-ecr-repo" {
  name = "razzia-app"
}

resource "aws_ecs_task_definition" "my-ecs-task-definition" {
  family                   = "razzia-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn


  container_definitions = jsonencode([
    {
      name      = "razzia-app"
      image     = "${data.aws_ecr_repository.my-ecr-repo.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 3000
        }
      ]

      secrets = [
        {
          name      = "MANAGER_PASSWORD"
          valueFrom = aws_secretsmanager_secret.app-password.arn
        }
      ]
    },

  ])

}



# Creating a security group for the ecs service 
# Needs to allow load balancer in on port 3000

# Firewall for the containers (no rules here, they're added separately below)
resource "aws_security_group" "ecs-tasks-sg" {
  name   = "razzia-ecs-tasks-sg"
  vpc_id = var.my-vpc
}

# Incoming: only the load balancer can reach the containers, on port 3000
resource "aws_vpc_security_group_ingress_rule" "ecs-allow-alb" {
  security_group_id            = aws_security_group.ecs-tasks-sg.id
  referenced_security_group_id = var.alb-sg.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
}

# Outgoing: containers can reach anything (needed for ECR and Secrets Manager)
resource "aws_vpc_security_group_egress_rule" "ecs-allow-outbound" {
  security_group_id = aws_security_group.ecs-tasks-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# Creating the service - container
resource "aws_ecs_service" "razzia-ecs-service" {
  name            = "razzia-container"
  cluster         = aws_ecs_cluster.my-ecs-cluster.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.my-ecs-task-definition.id
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public-subnet.id, var.public-subnet-2.id]
    security_groups  = [aws_security_group.ecs-tasks-sg.id]
    assign_public_ip = true
  }


  load_balancer {
    target_group_arn = var.alb-target-group.arn
    container_name   = "razzia-app"
    container_port   = 3000
  }

  depends_on = [var.alb-listener-443]

}

