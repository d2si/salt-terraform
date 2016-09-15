variable "region" { 
    type = "string"
    default = "eu-west-1"
}
variable "application" {
    type = "string"
    default = "saltstack"
}
variable "owner" {
    type = "string"
    default = "d2si" 
}
variable "state_bucket" {
    type = "string"
}
variable "state_key" {
    type = "string"
}
variable "trusted_networks" {
    type = "list"
    default = [ "0.0.0.0/0" ]
}
variable "key_name" {
    type = "string"
}

variable "master_instance_type" {
    type = "string"
    default = "t2.micro" 
}
variable "minion_instance_type" {
    type = "string"
    default = "t2.micro"
}

variable "minions_asg_min_size" { 
    type = "string"
    default = "1"
}
variable "minions_asg_max_size" {
    type = "string"
    default = "4"
}
variable "minions_asg_desired" {
    type = "string"
    default = "2"
}

