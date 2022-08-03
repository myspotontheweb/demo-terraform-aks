
variable "name" {
   type     = string
   nullable = false
}

variable "resource_group_location" {
   type     = string
   nullable = false
}

variable "registry_name" {
  type     = string
  nullable = false
}

variable "kubernetes_version" {
  type    = string
  default = "1.23.8"
}

variable "environment_tag" {
  type    = string
  default = "Development"
}

variable "dns_zone_name" {
   type     = string
   nullable = false
}

variable "dns_zone_resource_group_name" {
   type     = string
   nullable = false
}
