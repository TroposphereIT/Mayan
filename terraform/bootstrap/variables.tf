variable "aws_region" {
  description = "AWS region for Mayan infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "terraform_state_bucket" {
  description = "S3 bucket used for Terraform remote state"
  type        = string
  default     = "troposphereit-mayan-tfstate-650555452381"
}
