terraform {
  backend "s3" {
    bucket = "troposphereit-mayan-tfstate-650555452381"
    key    = "mayan/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
