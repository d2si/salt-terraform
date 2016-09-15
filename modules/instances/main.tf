variable ami_id {
  type = "string"
}

variable type {
  type = "string"
}

variable key {
  type    = "string"
  default = ""
}

variable subnet {
  type = "string"
}

variable security_groups {
  type = "list"
}

variable name {
  type = "string"
}

variable user_data {
  type    = "string"
  default = ""
}

variable private_zone_id {
  type    = "string"
  default = ""
}

variable record_ttl {
  type    = "string"
  default = "300"
}

variable reverse_zone_id {
  type    = "string"
  default = ""
}

variable domain_name {
  type    = "string"
  default = ""
}

data "template_file" "user_data" {
  template = "${file("${path.module}/files/hostname.tpl.sh")}"

  vars {
    hostname = "${var.name}"
  }
}

resource "aws_instance" "instance" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.type}"
  key_name               = "${var.key}"
  subnet_id              = "${var.subnet}"
  vpc_security_group_ids = ["${var.security_groups}"]
  user_data              = "${data.template_file.user_data.rendered}\n${var.user_data}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route53_record" "dns_record" {
#  count   = "${length(compact(split(",", var.private_zone_id)))}"
  zone_id = "${var.private_zone_id}"
  name    = "${var.name}"
  type    = "A"
  ttl     = "${var.record_ttl}"
  records = ["${aws_instance.instance.private_ip}"]
}

resource "aws_route53_record" "dns_reverse" {
#  count   = "${length(compact(split(",", var.reverse_zone_id)))}"
  zone_id = "${var.reverse_zone_id}"
  name    = "${replace(aws_instance.instance.private_ip,"/([0-9]+).([0-9]+).([0-9]+).([0-9]+)/","$4.$3")}"
  type    = "PTR"
  ttl     = "${var.record_ttl}"
  records = ["${var.name}.${var.domain_name}"]
}

output "public_ip" {
  value = "${aws_instance.instance.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.instance.public_dns}"
}

output "private_ip" {
  value = "${aws_instance.instance.private_dns}"
}

output "private_dns" {
  value = "${aws_instance.instance.private_dns}"
}
