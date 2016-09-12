variable  "aws_account_id"            {}
variable  "region"                    {}
variable  "application"               {}
variable  "owner"                     {}

variable  "azs"                       { default { "eu-west-1"  = "eu-west-1a,eu-west-1b,eu-west-1c"} }
variable  "cidr_block"                {}
variable  "subnet_bits"               {}
variable  "subnet_prv_offset"         {}
variable  "vpc_name"                  {}
variable  "vpc_short_name"            {}
