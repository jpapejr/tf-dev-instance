resource "ibm_resource_group" "group" {
  name = "dev"
}

resource "ibm_is_vpc" "vpc" {
  name = "dev"
  resource_group = ibm_resource_group.group.id
  address_prefix_management = "manual"
  depends_on = [ibm_resource_group.group]

}

resource "ibm_is_vpc_address_prefix" "prefix" {
  cidr = "10.10.0.0/16"
  name = "dev-prefix"
  vpc = ibm_is_vpc.vpc.id 
  zone = var.zone
  depends_on = [ibm_is_vpc.vpc]
}

resource "ibm_is_public_gateway" "zonepgw" {
  name = "${var.zone}-pgw"
  resource_group = ibm_resource_group.group.id 
  vpc = ibm_is_vpc.vpc.id
  zone = var.zone
}

resource "ibm_is_subnet" "nlbnet" { #find/replace `devbundle` for each new bundle
  ipv4_cidr_block = "10.10.0.0/28"
  name = "dev-alb"
  resource_group = ibm_resource_group.group.id 
  vpc = ibm_is_vpc.vpc.id
  zone = var.zone
  depends_on = [ibm_is_vpc_address_prefix.prefix]
}