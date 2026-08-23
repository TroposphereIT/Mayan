module "vpc" {
  source = "../../modules/vpc"

  name                 = "mayan-dev"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = {
    Application = "Mayan-EDMS"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "mayan-dev-eks"
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = ["t3.large"]

  desired_size = 2
  min_size     = 2
  max_size     = 4

  tags = {
    Application = "Mayan-EDMS"
    Environment = "dev"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = "mayan/mayan-edms"

  tags = {
    Application = "Mayan-EDMS"
    Environment = "dev"
  }
}
