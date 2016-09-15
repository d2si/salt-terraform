provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags {
    Name        = "${var.vpc_name}"
    Application = "${var.application}"
    Owner       = "${var.owner}"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  count      = "${length(var.azs[var.region])}"
  cidr_block = "${cidrsubnet(var.cidr_block, var.subnet_bits, count.index) }"

  availability_zone       = "${element(var.azs[var.region],count.index)}"
  map_public_ip_on_launch = "true"

  tags {
    Name        = "${var.vpc_name}_public_${count.index}"
    Application = "${var.application}"
    Owner       = "${var.owner}"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  count      = "${length(var.azs[var.region])}"
  cidr_block = "${cidrsubnet(var.cidr_block, var.subnet_bits, var.subnet_prv_offset +count.index) }"

  availability_zone       = "${element(var.azs[var.region],count.index)}"
  map_public_ip_on_launch = "false"

  tags {
    Name        = "${var.vpc_name}_private_${count.index}"
    Application = "${var.application}"
    Owner       = "${var.owner}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.vpc_name}_igw"
    Application = "${var.application}"
    Owner       = "${var.owner}"
  }
}

resource "aws_eip" "ng" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.ng.id}"
  subnet_id     = "${aws_subnet.public.0.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name        = "${var.vpc_name}_public_RIB"
    Application = "${var.application}"
    Owner       = "${var.owner}"
  }
}

resource "aws_route_table_association" "rtap" {
  count          = "${length(var.azs[var.region])}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.vpc_name}_private_RIB"
    Application = "${var.application}"
    Owner       = "${var.owner}"
  }
}

resource "aws_route" "private_default" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.gw.id}"
}

resource "aws_route_table_association" "rtaprv" {
  count          = "${length(var.azs[var.region])}"
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.id}"
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "region" {
  value = "${var.region}"
}

output "azs" {
  value = "${lookup(var.azs,var.region)}"
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "public_subnets_cidr_block" {
  value = ["${aws_subnet.public.*.cidr_block}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "private_subnets_cidr_block" {
  value = ["${aws_subnet.private.*.cidr_block}"]
}

output "vpc_short_name" {
  value = "${var.vpc_short_name}"
}

output "application" {
  value = "${var.application}"
}

output "owner" {
  value = "${var.owner}"
}
