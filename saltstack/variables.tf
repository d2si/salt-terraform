variable "region" { default = "eu-west-1" }
variable "application" {}
variable "owner" {}
variable "state_bucket" {}
variable "state_key" {}
variable "trusted_networks" {}
variable "key_name" {}
variable "ami_id" {}
variable "private_cidr" {}

variable "master_instance_type" {}
variable "minion_instance_type" {}

variable "minions_asg_max_size" {}
variable "minions_asg_min_size" {}
variable "minions_asg_desired" {}

