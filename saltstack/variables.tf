variable "region" { default = "eu-west-1" }
variable "application" { default = "saltstack" }
variable "owner" { default = "d2si" }
variable "state_bucket" {}
variable "state_key" {}
variable "trusted_networks" { default = "0.0.0.0/0" }
variable "key_name" {}

variable "master_instance_type" { default = "t2.micro" }
variable "minion_instance_type" { default = "t2.micro" }

variable "minions_asg_min_size" { default = "1"}
variable "minions_asg_max_size" { default = "4" }
variable "minions_asg_desired" { default = "2"}

