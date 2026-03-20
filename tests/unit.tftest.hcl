# Basic validation tests for the ALB module

mock_provider "aws" {}

variables {
  vpc_id             = "vpc-12345678"
  vpc_cidr_block     = "10.0.0.0/16"
  private_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  name_prefix        = "test-alb"
  environment        = "test"
  listener_port      = 80
  listener_protocol  = "HTTP"
  target_group_port  = 80
  target_group_protocol = "HTTP"
  common_tags = {
    Project   = "Testing"
    ManagedBy = "Terraform-Test"
  }
}

run "validate_defaults_and_resources" {
  command = plan

  assert {
    condition     = aws_lb.alb.internal == true
    error_message = "ALB should be internal by default as per variable default value."
  }

  assert {
    condition     = length(aws_security_group.sg_alb) == 1
    error_message = "A security group should be created by default when create_security_group is true."
  }

  assert {
    condition     = aws_lb_target_group.app_target_group.port == 80
    error_message = "Target group port does not match input variable."
  }
}

run "validate_name_prefix_length" {
  command = plan

  variables {
    name_prefix = "this-is-a-very-long-prefix-for-resource-naming-validation"
  }

  expect_failures = [
    var.name_prefix
  ]
}

run "validate_invalid_listener_port" {
  command = plan

  variables {
    listener_port = 70000
  }

  expect_failures = [
    var.listener_port
  ]
}

run "validate_invalid_protocol" {
  command = plan

  variables {
    listener_protocol = "FTP"
  }

  expect_failures = [
    var.listener_protocol
  ]
}

run "validate_https_requires_certificate" {
  command = plan

  variables {
    listener_protocol = "HTTPS"
    certificate_arn   = null
  }

  # This should trigger the lifecycle precondition in aws_lb_listener.app_listener
  expect_failures = [
    aws_lb_listener.app_listener
  ]
}

run "validate_no_security_group_creation" {
  command = plan

  variables {
    create_security_group = false
    security_group_ids    = ["sg-12345678"]
  }

  assert {
    condition     = length(aws_security_group.sg_alb) == 0
    error_message = "Security group should not be created when create_security_group is false."
  }
}
