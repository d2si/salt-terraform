variable  "region"                    { default = "eu-west-1" }
variable  "application"               { default = "saltstack" }
variable  "owner"                     { default = "d2si" }

variable  "azs"                       { default { "eu-west-1"  = "eu-west-1a,eu-west-1b,eu-west-1c"} }
variable  "cidr_block"                { default = "10.242.0.0/16" }
variable  "subnet_bits"               { default = "8" }
variable  "subnet_prv_offset"         { default = "8" }
variable  "vpc_name"                  { default = "Salt" }
variable  "vpc_short_name"            { default = "Salt" }
