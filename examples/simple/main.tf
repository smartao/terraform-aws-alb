module "alb" {
  source = "../../"

  name_prefix        = "my-app"
  environment        = "dev"
  vpc_id             = "vpc-12345678"
  vpc_cidr_block     = "10.0.0.0/16"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]

  listener_port     = 80
  listener_protocol = "HTTP"

  target_group_port     = 80
  target_group_protocol = "HTTP"

  common_tags = {
    Project   = "Demo"
    ManagedBy = "Terraform"
  }
}
