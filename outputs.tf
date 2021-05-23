output "consul_client_sg_id" {
  value = length(aws_security_group.consul_client) > 0 ? aws_security_group.consul_client[0].id : null
}