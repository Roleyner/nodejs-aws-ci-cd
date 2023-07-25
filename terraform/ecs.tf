resource "aws_ecs_cluster" "cluster" {
  name               = local.ecs["cluster_name"]
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = "100"
  }
}

resource "aws_ecs_task_definition" "task" {
  family = "service"
  requires_compatibilities = [
    "FARGATE",
  ]
  execution_role_arn = aws_iam_role.fargate.arn
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 512
  container_definitions = jsonencode([
    {
      name      = local.container.name
      image     = local.container.image
      essential = true
      log_configuration = {
        log_driver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "eu-west-2"         # Replace with your desired AWS region
          "awslogs-stream-prefix" = "my-container-logs" # Replace "my-container-logs" with your desired log stream prefix
        }
      }
      portMappings = [
        for port in local.container.ports :
        {
          containerPort = port
          hostPort      = port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = local.ecs.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  network_configuration {
    subnets          = [for s in data.aws_subnet.subnets : s.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.group.arn
    container_name   = local.container.name
    container_port   = 80
  }
  deployment_controller {
    type = "ECS"
  }
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }

  # Enable CloudWatch Logs for the service
  depends_on = [
    aws_cloudwatch_log_group.ecs_logs,
    aws_ecs_cluster.cluster,
    aws_ecs_task_definition.task
  ]
}

# Create a CloudWatch Logs group to store the container logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/ecs-logs" # Replace "my-ecs-logs" with your desired log group name
  retention_in_days = 7               # Set the desired retention period for log data
}