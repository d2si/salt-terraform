variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "application" {
  type    = "string"
  default = "saltstack"
}

variable "owner" {
  type    = "string"
  default = "d2si"
}

variable "azs" {
  type = "map"

  default {
    "eu-west-1" = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  }
}

variable "cidr_block" {
  type    = "string"
  default = "10.242.0.0/16"
}

variable "subnet_bits" {
  type    = "string"
  default = "8"
}

variable "subnet_prv_offset" {
  type    = "string"
  default = "8"
}

variable "vpc_name" {
  type    = "string"
  default = "Salt"
}

variable "vpc_short_name" {
  type    = "string"
  default = "Salt"
}
