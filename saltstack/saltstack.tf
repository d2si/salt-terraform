data "terraform_remote_state" "common" {
  backend = "s3"

  config {
    bucket = "${var.state_bucket}"
    key    = "${var.state_key}"
    region = "${var.region}"
  }
}

provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "salt" {
  most_recent = true

  filter {
    name   = "name"
    values = "${list(var.ami_basenames["${var.salt_distrib}"])}"
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "saltmaster" {
  source = "../modules/instances"
  name   = ["salt"]

  ami_id          = "${data.aws_ami.salt.id}"
  type            = "${var.master_instance_type}"
  key             = "${var.key_name}"
  subnet          = "${data.terraform_remote_state.common.public_subnets}"
  security_groups = ["${aws_security_group.sg_admin.id}", "${aws_security_group.sg_saltmaster.id}"]

  user_data = "${file("scripts/master-bootstrap.sh")}"

  private_zone_id = "${data.terraform_remote_state.common.private_host_zone}"
  reverse_zone_id = "${data.terraform_remote_state.common.private_host_zone_reverse}"
  domain_name     = "${data.terraform_remote_state.common.private_domain_name}"
}

module "saltminions" {
  source = "../modules/instances"
  name   = ["minion1", "minion2"]

  ami_id          = "${data.aws_ami.salt.id}"
  type            = "${var.minion_instance_type}"
  key             = "${var.key_name}"
  subnet          = "${data.terraform_remote_state.common.public_subnets}"
  security_groups = ["${aws_security_group.sg_admin.id}", "${aws_security_group.sg_minion.id}"]

  user_data = "${file("scripts/minion-bootstrap.sh")}"

  private_zone_id = "${data.terraform_remote_state.common.private_host_zone}"
  reverse_zone_id = "${data.terraform_remote_state.common.private_host_zone_reverse}"
  domain_name     = "${data.terraform_remote_state.common.private_domain_name}"
}

# Security group for server administration
resource "aws_security_group" "sg_admin" {
  name   = "sg_admin"
  vpc_id = "${data.terraform_remote_state.common.vpc_id}"

  # SSH from trustednetworks
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${var.trusted_networks}"]
  }
}

# Security group for server administration
resource "aws_security_group" "sg_minion" {
  name   = "sg_minion"
  vpc_id = "${data.terraform_remote_state.common.vpc_id}"

  # Goes Anywhere with any protocol
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for salt master
resource "aws_security_group" "sg_saltmaster" {
  name   = "sg_saltmaster"
  vpc_id = "${data.terraform_remote_state.common.vpc_id}"

  # saltstack ports (zeroMQ)
  ingress {
    from_port       = "4505"
    to_port         = "4506"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg_minion.id}"]
  }

  # Goes Anywhere with any protocol
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.application}"
  }
}

output "saltmaster_private_dns" {
  value = "${module.saltmaster.private_dns}"
}

output "saltmaster_private_ip" {
  value = "${module.saltmaster.private_ip}"
}

output "saltmaster_public_ip" {
  value = "${module.saltmaster.public_ip}"
}

output "saltminions_private_dns" {
  value = "${module.saltminions.private_dns}"
}

output "saltminions_private_ip" {
  value = "${module.saltminions.private_ip}"
}

output "saltminions_public_ip" {
  value = "${module.saltminions.public_ip}"
}
