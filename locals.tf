locals {
  # Defines which CIDR blocks are allowed to access the ALB. 
  # If 'allowed_ingress_cidr_blocks' is empty, it defaults to the entire VPC CIDR.
  alb_ingress_cidr_blocks = length(var.allowed_ingress_cidr_blocks) > 0 ? var.allowed_ingress_cidr_blocks : [coalesce(var.vpc_cidr_block, data.aws_vpc.selected.cidr_block)]

  # Defines which CIDR blocks the ALB can send traffic to (egress).
  # If 'allowed_egress_cidr_blocks' is empty, it defaults to the entire VPC CIDR.
  alb_egress_cidr_blocks = length(var.allowed_egress_cidr_blocks) > 0 ? var.allowed_egress_cidr_blocks : [coalesce(var.vpc_cidr_block, data.aws_vpc.selected.cidr_block)]

  # Consolidates the security group IDs for the ALB.
  # If 'create_security_group' is true, it includes the newly created SG along with any extra SGs provided.
  alb_security_group_ids = var.create_security_group ? concat([aws_security_group.sg_alb[0].id], var.security_group_ids) : var.security_group_ids

  listeners = {
    main = {
      port     = var.listener_port
      protocol = var.listener_protocol
    }
  }

  tls_protocols = ["HTTPS", "TLS"]
}
