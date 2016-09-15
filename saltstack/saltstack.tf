data "terraform_remote_state" "common" {
       backend = "s3"
       config {
           bucket = "${var.state_bucket}"
           key = "${var.state_key}"
           region = "${var.region}"
       }
}

provider "aws" {
    region = "${var.region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*" ]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

module "saltmaster" {
    source = "../modules/instances"
    ami_id = "${data.aws_ami.ubuntu.id}"
    type = "${var.master_instance_type}"
    key = "${var.key_name}"
    subnet = "${data.terraform_remote_state.common.public_subnets[0]}"
    security_groups = ["${aws_security_group.sg_salt.id}"]
    name = "saltmaster"

    user_data = "${file("scripts/master-bootstrap.sh")}"

    private_zone_id = "${data.terraform_remote_state.common.private_host_zone}"
    reverse_zone_id = "${data.terraform_remote_state.common.private_host_zone_reverse}"
    domain_name = "${data.terraform_remote_state.common.private_domain_name}"
}

# Security group for salt instance
resource "aws_security_group" "sg_salt" {
    name = "sg_salt"
    vpc_id = "${data.terraform_remote_state.common.vpc_id}"

    # SSH from trustednetworks
    ingress {
      from_port = "22"
      to_port = "22"
      protocol = "tcp"
      cidr_blocks = [ "${var.trusted_networks}" ]
    }

    # saltstack ports (zeroMQ)
    ingress {
      from_port = "4505"
      to_port = "4506"
      protocol = "tcp"
      cidr_blocks = [ "${data.terraform_remote_state.common.private_subnets_cidr_block}" ]
    }

    # Goes Anywhere with any protocol
    egress {
      from_port = "0"
      to_port = "0"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags { Name = "${var.application}" }
}

resource "aws_launch_configuration" "lc_minions" {

  name_prefix = "lc-salt-minions-"
  image_id = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.minion_instance_type}"
  user_data = "${file("scripts/master-bootstrap.sh")}"

  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_minions" {
    name = "asg-salt-minions"
    launch_configuration = "${aws_launch_configuration.lc_minions.name}"
    vpc_zone_identifier = [ "${data.terraform_remote_state.common.private_subnets}" ]
    min_size = "${var.minions_asg_min_size}"
    max_size = "${var.minions_asg_max_size}"
    desired_capacity = "${var.minions_asg_desired}"
    health_check_grace_period = 300
    health_check_type = "EC2"

    lifecycle {
      create_before_destroy = true
    }

    tag {
        key  =  "Application"
        value = "${var.application}"
        propagate_at_launch = true
    }

    tag {
      key   = "Owner"
      value =  "${var.owner}"
      propagate_at_launch = true
    }
}


output  "saltmaster_public_ip"            {  value  =  "${module.saltmaster.public_ip}" }
output  "saltmaster_public_dns"            {  value  =  "${module.saltmaster.public_dns}" }
output  "saltmaster_private_ip"            {  value  =  "${module.saltmaster.private_dns}" }
output  "saltmaster_private_dns"            {  value  =  "${module.saltmaster.private_dns}" }
output  "minions_asg"                     {  value  =  "${aws_autoscaling_group.asg_minions.name}" }
output  "application"                     {  value  =  "${var.application}" }
output  "owner"                           {  value  =  "${var.owner}" }
