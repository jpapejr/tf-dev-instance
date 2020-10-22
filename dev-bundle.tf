resource "ibm_is_subnet" "devbundle" { #find/replace `devbundle` for each new bundle
  ipv4_cidr_block = "10.10.1.0/28" #change this with each additional bundle added, I.e. 3rd octet++
  name = "devbundle-subnet"
  resource_group = ibm_resource_group.group.id 
  vpc = ibm_is_vpc.vpc.id
  zone = var.zone
  public_gateway = ibm_is_public_gateway.zonepgw.id
  depends_on = [ibm_is_vpc_address_prefix.prefix]
}


resource "ibm_is_security_group" "devbundle" {
  name = "devbundle-sg"
  resource_group = ibm_resource_group.group.id 
  vpc = ibm_is_vpc.vpc.id
}

resource "ibm_is_security_group_rule" "devbundle" {
  direction = "inbound"
  group     = ibm_is_security_group.devbundle.id
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
  ip_version = "ipv4"
  depends_on = [ibm_is_security_group.devbundle]
}

resource "ibm_is_security_group_rule" "devbundle-2" {
  direction = "outbound"
  group     = ibm_is_security_group.devbundle.id
  remote    = "0.0.0.0/0"
  tcp {}
  ip_version = "ipv4"
  depends_on = [ibm_is_security_group.devbundle]
}

resource "ibm_is_security_group_rule" "devbundle-3" {
  direction = "inbound"
  group     = ibm_is_security_group.devbundle.id
  remote    = ibm_is_security_group.devbundle.id
  tcp {}
  ip_version = "ipv4"
  depends_on = [ibm_is_security_group.devbundle]
}

# Create a new ssh key
resource "tls_private_key" "devbundle" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "devbundle" {
  name = "devbundle-key"
  resource_group = ibm_resource_group.group.id
  public_key = tls_private_key.devbundle.public_key_openssh
  depends_on = [tls_private_key.devbundle]

}

resource "ibm_is_instance" "devbundle" {
  name = "devbundle-instance"
  primary_network_interface {
    name            = "eth0"
    security_groups = [ibm_is_security_group.devbundle.id, ibm_is_vpc.vpc.default_security_group]
    subnet          = ibm_is_subnet.devbundle.id
  }
  keys           = [ibm_is_ssh_key.devbundle.id]
  resource_group = ibm_resource_group.group.id
  profile        = "cx2-4x8"
  zone           = var.zone
  vpc            = ibm_is_vpc.vpc.id
  image          = "r014-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
  user_data      = file("${path.module}/bootstrap.sh")
  depends_on     = [ibm_is_subnet.devbundle, ibm_is_security_group.devbundle, ibm_is_security_group_rule.devbundle-2, ibm_is_ssh_key.devbundle]
}

output "instance_ip_devbundle" {
  value = ibm_is_instance.devbundle.primary_network_interface[0].primary_ipv4_address
}

output "private_key_devbundle" {
    value = tls_private_key.devbundle.private_key_pem
}