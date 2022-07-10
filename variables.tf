variable "region" {
        default = "sa-east-1"
}

variable "vpc_id" {
        default = "vpc-00d318417873e5516"
}

variable "ecs_cluster_name" {
        default = "infraecsfargate-dev"
}

variable "service_name" {
        default = "ecs-app"
}

variable "cpu" {
        default = "256"
}

variable "memory" {
        default = "512"
}

variable "image_ecr" {
        default = "033218463512.dkr.ecr.sa-east-1.amazonaws.com/tklabs:latest"
}

variable "fargate_subnets" {
        default = "172.31.16.0/20, 172.31.0.0/20, 172.31.32.0/20"
}

variable "queue_name" {
        default = "arn:aws:sqs:sa-east-1:033218463512:myqueue"
}