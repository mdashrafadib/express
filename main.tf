# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}

# Set variables for VPC and subnet IDs
variable "vpc_id" {
  default = "vpc-0c14f7d11039154d4"
}

variable "subnet_ids" {
  default = ["subnet-0d8a051a7ff4c067e", "subnet-09b853efd21f77270"]
}

# Set variable for security group ID
variable "security_group_id" {
  default = "sg-01007d8613a6f31ea"
}

# Create an ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
 
}

# Create a task definition for a Docker container
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task"
  container_definitions    = <<DEFINITION
[
  {
    "name": "my-container",
    "image": "mdashrafadib/expressjs:latest",
    "cpu": 256,
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "essential": true
  }
]
DEFINITION
  
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # Add the cpu parameter
  memory                   = 512
}

# Create an ECS service
resource "aws_ecs_service" "my_service" {
  name                  = "my-service"
  cluster               = aws_ecs_cluster.my_cluster.id
  task_definition       = aws_ecs_task_definition.my_task_definition.arn
  desired_count         = 1
  launch_type           = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    container_name   = "my-container"
    container_port   = 80
  }
  
}

# Create an ALB for the ECS service
resource "aws_lb" "my_load_balancer" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids

  tags = {
    Environment = "dev"
  }
}

# Create an ALB listener to forward traffic to the ECS service
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
# Create an ALB target group for the ECS service
resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 30
    timeout             = 5
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

