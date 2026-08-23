output "terraform_state_bucket" {
  description = "Terraform remote state S3 bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "Terraform remote state S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}
