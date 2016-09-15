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

variable "master_instance_type" {
  default = "t2.micro"
}

variable "minion_instance_type" {
  default = "t2.micro"
}

variable "trusted_networks" {}

variable "key_name" {
  default = "grk-us-west-1"
}

variable "ami_id" {}


variable "private_cidr" {}

variable "minions_asg_max_size" {
  default = "5"
}

variable "minions_asg_min_size" {
  default = "1"
}

variable "minions_asg_desired" {
  default = "2"
}

