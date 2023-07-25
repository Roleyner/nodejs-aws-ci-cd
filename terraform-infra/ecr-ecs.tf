resource "aws_ecr_repository" "repository" {
  name = var.repository_name
}

resource "aws_ecs_cluster" "cluster" {
  name               = var.cluster_name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = "100"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.fargate.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.image_name
      essential = true
      log_configuration = {
        log_driver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "container-logs"
        }
      }
      portMappings = [
        {
          containerPort = 3000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 2

  network_configuration {
    subnets          = [for s in data.aws_subnet.subnets : s.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_service_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.group.arn
    container_name   = var.container_name
    container_port   = 3000
  }
  deployment_controller {
    type = "ECS"
  }
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }

  depends_on = [
    aws_cloudwatch_log_group.ecs_logs,
    aws_ecs_cluster.cluster,
    aws_ecs_task_definition.task
  ]
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/ecs-logs"
  retention_in_days = 7
}