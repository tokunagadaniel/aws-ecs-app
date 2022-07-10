variable "region" {
        default = "sa-east-1"
}

variable "vpc_id" {
        default = "sa-east-1"
}

variable "ecs_cluster_name" {
        default = "myqueue"
}

variable "service_name" {
        default = "ecs-app"
}

variable "cpu" {
        default = "512"
}

variable "memory" {
        default = "512"
}

variable "image_ecr" {
        default = "033218463512.dkr.ecr.sa-east-1.amazonaws.com/tklabs:latest"
}

variable "fargate_subnets" {
        default = "ecs-app"
}

variable "queue_name" {
        default = "myqueue"
}