variable "region" {
  default = "eu-west-1"
}

variable  "application" {
  default = "saltstack"
}
variable  "owner" {
  default = "grk"
}

variable "state_bucket" {
  default = "grkoffi-tfstates"
}
variable "state_key" {
  default = "common/infra.tfstate"
}


variable "instance_type" {
  default = "t2.micro"
}

variable "trusted_networks" {}

variable "key_name" {
  default = "grk-us-west-1"
}

variable "ami_id" {}
