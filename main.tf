provider "aws" {
  region = var.region
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = var.ecs_cluster_name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${var.service_name}"
  assume_role_policy = <<ASSUME_ROLE_POLICY
{
"Version": "2012-10-17",
"Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
ASSUME_ROLE_POLICY
}

data "aws_iam_policy" "amazon_ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "policy_role_attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.amazon_ecs_task_execution_role_policy.arn
}

resource "aws_iam_role" "task_role" {
  name = "ecsTaskRole-${var.service_name}"
  assume_role_policy = <<ASSUME_ROLE_POLICY
{
"Version": "2012-10-17",
"Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
ASSUME_ROLE_POLICY
}
resource "aws_iam_policy" "ecs_task_role_policy" {
  name = "ecsTaskRolePolicy-${var.service_name}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  role = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/aws/ecs/${var.service_name}"
}


resource "aws_ecs_task_definition" "task_definition" {
  family = var.service_name
  requires_compatibilities = [
    "FARGATE"]
  network_mode = "awsvpc"
  cpu = var.cpu
  memory = var.memory
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.task_role.arn

  container_definitions = <<TASK_DEFINITION
  [
    {
        "essential": true,
        "image": "${var.image_ecr}",
        "name": "${var.service_name}",
        "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                  "awslogs-region": "${var.region}",
                  "awslogs-group": "${aws_cloudwatch_log_group.ecs_log_group.name}",
                  "awslogs-stream-prefix": "${var.service_name}"
            }
        }
    }
  ]
  TASK_DEFINITION
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "security_group" {
  name = var.service_name
  vpc_id = data.aws_vpc.vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = var.service_name
  }
}

resource "aws_ecs_service" "service" {
  name = var.service_name
  cluster = data.aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.id
  desired_count = 0
  launch_type = "FARGATE"

  network_configuration {
    subnets = ["${var.fargate_subnets}"]
    security_groups = [
      aws_security_group.security_group.id]
  }
}


data "aws_iam_role" "ecs_autoscaling_role" {
  name = "AWSServiceRoleForAutoScaling"
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity = 10
  min_capacity = 0
  resource_id = "service/${data.aws_ecs_cluster.ecs_cluster.cluster_name}/${var.service_name}"
  role_arn = data.aws_iam_role.ecs_autoscaling_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up_fargate" {
  policy_type = "StepScaling"
  name = "sqs-scaling-up-${var.service_name}"
  resource_id = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ExactCapacity"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 500
      scaling_adjustment = 1
    }
    step_adjustment {
      metric_interval_lower_bound = 500
      metric_interval_upper_bound = 1000
      scaling_adjustment = 2
    }
    step_adjustment {
      metric_interval_lower_bound = 1000
      metric_interval_upper_bound = 1500
      scaling_adjustment = 3
    }
    step_adjustment {
      metric_interval_lower_bound = 1500
      metric_interval_upper_bound = 2000
      scaling_adjustment = 4
    }
    step_adjustment {
      metric_interval_lower_bound = 2000
      metric_interval_upper_bound = 2500
      scaling_adjustment = 5
    }
    step_adjustment {
      metric_interval_lower_bound = 2500
      metric_interval_upper_bound = 3000
      scaling_adjustment = 6
    }
    step_adjustment {
      metric_interval_lower_bound = 3000
      metric_interval_upper_bound = 3500
      scaling_adjustment = 7
    }
    step_adjustment {
      metric_interval_lower_bound = 3500
      metric_interval_upper_bound = 4000
      scaling_adjustment = 8
    }
    step_adjustment {
      metric_interval_lower_bound = 4000
      metric_interval_upper_bound = 4500
      scaling_adjustment = 9
    }
    step_adjustment {
      metric_interval_lower_bound = 4500
      scaling_adjustment = 10
    }

  }
}


resource "aws_appautoscaling_policy" "scale_down_fargate" {
  policy_type = "StepScaling"
  name = "sqs-scaling-down-${var.service_name}"
  resource_id = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ExactCapacity"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment = 0
    }

  }
}


resource "aws_cloudwatch_metric_alarm" "sqs_scale_out" {
  alarm_name = "SQS-ScaleOut-${var.service_name}"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace = "AWS/SQS"
  period = "60"
  threshold = "1"
  statistic = "Sum"
  alarm_description = "SQS-ScaleOut-${var.service_name}"
  insufficient_data_actions = []
  alarm_actions = [
    aws_appautoscaling_policy.scale_up_fargate.arn]

  dimensions = {
    QueueName = var.queue_name
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_scale_in" {
  alarm_name = "SQS-ScaleIn-${var.service_name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace = "AWS/SQS"
  period = "60"
  threshold = "1"
  statistic = "Sum"
  alarm_description = "SQS-ScaleIn-${var.service_name}"
  alarm_actions = [
    aws_appautoscaling_policy.scale_down_fargate.arn]


  dimensions = {
    QueueName = var.queue_name
  }
}