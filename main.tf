locals {
  extra_tags = {
    role  = "consul_client_vault_vpc"
    route = "public"
  }
  name              = var.name
  security_group_id = length(aws_security_group.consul_client) > 0 ? aws_security_group.consul_client[0].id : null
}

variable "create_vpc" {
    type = bool
}

variable "permitted_cidr_list" {
    type = list(string)
}

variable "vpc_id" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "common_tags" {
  description = "A map of common tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}

output "consul_client_sg_id" {
    value = element( concat( aws_security_group.consul_client.*.id, tolist([""]) ), 0 )
}

resource "aws_security_group" "consul_client" {
  count       = var.create_vpc ? 1 : 0
  name        = local.name
  description = "Security group for Consul Clients"
  vpc_id      = var.vpc_id
  tags        = merge(tomap({ "Name" : local.name }), var.common_tags, local.extra_tags)
}

module "security_group_rules" {
  count  = var.create_vpc ? 1 : 0
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-client-security-group-rules?ref=v0.8.0"

  allowed_inbound_security_group_ids   = var.allowed_inbound_security_group_ids
  allowed_inbound_security_group_count = var.allowed_inbound_security_group_count
  allowed_inbound_cidr_blocks          = var.allowed_inbound_cidr_blocks

  security_group_id = local.security_group_id
}

resource "aws_security_group_rule" "allow_inbound" {
  count       = var.create_vpc ? 1 : 0
  type        = "ingress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "all incoming traffic"

  security_group_id = local.security_group_id
}