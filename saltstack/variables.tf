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

variable "state_bucket" {
  type = "string"
}

variable "state_key" {
  type = "string"
}

variable "trusted_networks" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

variable "key_name" {
  type = "string"
}

variable "master_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "minion_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "ami_basenames" {
  type = "map"

  default = {
    "debian-8.4"   = "debian-jessie-amd64-hvm*"
    "ubuntu-16.04" = "ubuntu/images-milestone/hvm-ssd/ubuntu-xenial-16.04*"
  }
}

variable "salt_distrib" {
  type    = "string"
  default = "ubuntu-16.04"
}
