# 📦 terraform-aws-alb

This Terraform module provides a flexible and production-ready solution for deploying an **AWS Application Load Balancer (ALB)**. It handles the creation of the ALB, target groups, listeners, and a dedicated security group with configurable ingress/egress rules for enhanced security.

This module is designed for reuse through the HashiCorp Registry and provides a robust starting point for exposing applications within your VPC.

## ⚙️ Features

- **Security First**: Automatically creates a dedicated security group for the ALB with strict rules for listener access and target communication.
- **Flexible Networking**: Supports both internal and external (public-facing) load balancers.
- **Protocol Support**: Fully supports HTTP and HTTPS (ACM certificate required for HTTPS) listeners.
- **Health Checks**: Configurable health checks for the target group to ensure traffic is only routed to healthy instances.
- **Scalability**: Designed to be integrated with existing VPCs and subnets.
- **Production Ready**: Includes advanced settings like deletion protection, HTTP/2, and drop invalid headers.

## 🏗️ Architecture

The module creates:

- 1 Application Load Balancer
- 1 Dedicated Security Group (with configurable ingress/egress rules)
- 1 Target Group (Instance-based)
- 1 Listener (HTTP or HTTPS)

## 🚀 Quick Start

```hcl
module "alb" {
  source = "smartao/terraform-aws-alb/aws"
  version = "~> 1.0.0"

  name_prefix       = "app-production"
  environment       = "prod"
  vpc_id            = "vpc-xxxxxxxxxxxx"
  vpc_cidr_block    = "10.0.0.0/16"
  private_subnet_ids = ["subnet-xxxxxxxxxxxx", "subnet-yyyyyyyyyyyy"]

  listener_port     = 80
  listener_protocol = "HTTP"

  target_group_port     = 80
  target_group_protocol = "HTTP"

  common_tags = {
    Project   = "Nexus"
    Owner     = "DevOps Team"
    CostCenter = "CO-12345"
  }
}
```

## 📘 Example Usage

If you want to test the module from this repository checkout, see the local example in [examples/simple/main.tf](examples/simple/main.tf).

You can run it with:

```bash
cd examples/simple
terraform init
terraform plan
```

Additional notes for the example are documented in [examples/simple/README.md](examples/simple/README.md).

## 📑 Requirements and Assumptions

- `private_subnet_ids` must contain at least two subnets in different Availability Zones.
- `name_prefix` must be 32 characters or fewer.
- `listener_protocol` and `target_group_protocol` must be either `HTTP` or `HTTPS`.
- `health_check_path` must start with `/`.
- `health_check_timeout` must be less than `health_check_interval`.
- When using `HTTPS`, a valid `certificate_arn` must be provided.
- At least one security group must be attached (either created by the module or provided via `security_group_ids`).

## 🏷️ Tagging

All resources receive these baseline tags:

- `Environment = var.environment`
- `Name = "${var.name_prefix}-..."`
- Any additional tags provided in `var.common_tags`

## 📄 Operational Notes

- **Health Checks**: Are performed by the ALB. Ensure your application is configured to respond on the path and port specified.
- **Security Groups**: By default, the module creates a security group that allows traffic from the VPC CIDR or specific CIDRs/SGs you provide.
- **ACM Certificates**: For HTTPS, you must have an existing certificate in AWS Certificate Manager.
- **Deletion Protection**: Recommended for production environments.

## 🧪 Tests

This repository currently includes example configurations that can be used for manual verification. Automated tests can be executed if configured:

```bash
terraform init
terraform test
```

## 📜 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.app_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.app_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.sg_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_alb_to_app_targets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_http_from_cidrs_to_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_http_from_sgs_to_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_idle_timeout"></a> [alb\_idle\_timeout](#input\_alb\_idle\_timeout) | Time in seconds that the connection is allowed to be idle | `number` | `60` | no |
| <a name="input_allowed_egress_cidr_blocks"></a> [allowed\_egress\_cidr\_blocks](#input\_allowed\_egress\_cidr\_blocks) | CIDR blocks the ALB is allowed to reach on the target group port. Defaults to the VPC CIDR when empty. | `list(string)` | `[]` | no |
| <a name="input_allowed_ingress_cidr_blocks"></a> [allowed\_ingress\_cidr\_blocks](#input\_allowed\_ingress\_cidr\_blocks) | CIDR blocks allowed to reach the ALB listener. Defaults to the VPC CIDR when empty. | `list(string)` | `[]` | no |
| <a name="input_allowed_ingress_security_group_ids"></a> [allowed\_ingress\_security\_group\_ids](#input\_allowed\_ingress\_security\_group\_ids) | Security group IDs allowed to reach the ALB listener | `list(string)` | `[]` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the ACM certificate for HTTPS listeners. Required when listener\_protocol is HTTPS. | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | n/a | yes |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether the module should create and manage a dedicated security group for the ALB | `bool` | `true` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with invalid names are removed by the ALB | `bool` | `true` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Defines whether deletion protection is enabled on the ALB | `bool` | `false` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Defines whether HTTP/2 is enabled on the ALB | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag for resources | `string` | n/a | yes |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Approximate amount of time, in seconds, between health checks | `number` | `30` | no |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | The HTTP codes to use when checking for a successful response | `string` | `"200"` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The destination for the health check request | `string` | `"/"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Amount of time, in seconds, during which no response means a failed health check | `number` | `5` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | Number of consecutive successful health checks required before considering a target healthy | `number` | `2` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | If true, the LB will be internal. If false, the LB will be public-facing. | `bool` | `true` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | The port on which the ALB listener accepts connections | `number` | n/a | yes |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | The protocol used by the ALB listener (e.g., HTTP, HTTPS) | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming resources | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for application instances and internal ALB | `list(string)` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Additional security group IDs to attach to the ALB, or the full list when create\_security\_group is false | `list(string)` | `[]` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy for the HTTPS listener | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | The port on which the application targets receive traffic | `number` | n/a | yes |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | The protocol used by the ALB target group and health checks (e.g., HTTP, HTTPS) | `string` | n/a | yes |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | Number of consecutive failed health checks required before considering a target unhealthy | `number` | `2` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The VPC CIDR block used as a fallback when explicit ALB security group CIDR rules are not provided | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | The ARN of the Application Load Balancer |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the Application Load Balancer |
| <a name="output_app_target_group_arn"></a> [app\_target\_group\_arn](#output\_app\_target\_group\_arn) | The ARN of the ALB Target Group for the application |
| <a name="output_sg_alb_id"></a> [sg\_alb\_id](#output\_sg\_alb\_id) | The ID of the Security Group for the Application Load Balancer |
<!-- END_TF_DOCS -->