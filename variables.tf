variable "create_vpc" {
  type = bool
}
variable "vpc_id" {
  type = string
}
variable "common_tags" {
  description = "A map of common tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}