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

module "saltservers" {
    source = "../modules/instances"
    name = ["saltmaster", "minion1"]

    ami_id = "${data.aws_ami.ubuntu.id}"
    type = "${var.master_instance_type}"
    key = "${var.key_name}"
    subnet = "${data.terraform_remote_state.common.public_subnets}"
    security_groups = ["${aws_security_group.sg_salt.id}"]

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

output  "saltservers_private_dns"            {  value  =  "${module.saltservers.private_dns}" }
output  "saltservers_private_ip"            {  value  =  "${module.saltservers.private_ip}" }
output  "saltservers_public_ip"            {  value  =  "${module.saltservers.public_ip}" }
output  "minions_asg"                     {  value  =  "${aws_autoscaling_group.asg_minions.name}" }
output  "application"                     {  value  =  "${var.application}" }
output  "owner"                           {  value  =  "${var.owner}" }
