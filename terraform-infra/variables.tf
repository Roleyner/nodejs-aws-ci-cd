variable "region" {
  description = "AWS region"
}

variable "cluster_name" {
  description = "AWS ECS cluster name"
}

variable "service_name" {
  description = "AWS ECS service name"
}

variable "repository_name" {
  description = "AWS ECR repository name"
}

variable "container_name" {
  description = "Docker container name"
}

variable "image_name" {
  description = "Image used for docker containers"
}

variable "vpc_id" {
  description = "AWS VPC"
}