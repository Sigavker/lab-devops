variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1" # או eu-central-1 אם אתה מעדיף אירופה
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "lab-devops-vpc"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "lab-cluster"
}