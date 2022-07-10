variable "region" {
        default = "sa-east-1"
}

variable "vpc_id" {
        default = "vpc-00d318417873e5516"
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
        default = "[subnet-0d808f444bb2174f3, subnet-031ac19c8c68cd6e5, subnet-0aff4fb0f3141b3c9]"
}

variable "queue_name" {
        default = "arn:aws:sqs:sa-east-1:033218463512:myqueue"
}