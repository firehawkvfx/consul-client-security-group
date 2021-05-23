locals {
  extra_tags = {
    role  = "consul_client"
    route = "public"
  }
  name = "consul_client"
}
resource "aws_security_group" "consul_client" {
  count       = var.create_vpc ? 1 : 0
  name        = "consul_client"
  description = "Security group for Consul Clients"
  vpc_id      = var.vpc_id
  tags        = merge(map("Name", format("%s", local.name)), var.common_tags, local.extra_tags)
}

module "security_group_rules" {
  source            = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-client-security-group-rules?ref=v0.8.0"
  security_group_id = resource.aws_security_group.security_group_id
}

resource "aws_security_group_rule" "allow_inbound_api" {
  type        = "ingress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "all outgoing traffic"

  security_group_id = aws_security_group.consul_client.id
}
