# Create an IBM Ressource Group
resource "ibm_resource_group" "rg" {
  name = var.resources_group
}

# Create a VPC
resource "ibm_is_vpc" "vpc" {
  name = var.name_vpc
  resource_group = ibm_resource_group.rg.id
  address_prefix_management = "manual"
  #default_security_group_name = var.security_group
}

# Create a Security Group
 resource "ibm_is_security_group" "ocpbmesxi-securitygroup" {
   name = var.security_group
   vpc  = ibm_is_vpc.vpc.id
   resource_group = ibm_resource_group.rg.id
 }

# Create a Security Group Rule inbound
resource "ibm_is_security_group_rule" "ocpbmesxi-securitygroupruleinbound" {
  group     = ibm_is_security_group.ocpbmesxi-securitygroup.id
  #group  = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  #remote = "any"
  #remote    = "0.0.0.0/0"
  # all {
  #   port_min = 1
  #   port_max = 65535
  # }
}

# Create a Security Group Rule outbound
resource "ibm_is_security_group_rule" "ocpbmesxi-securitygroupruleoutbound" {
  group     = ibm_is_security_group.ocpbmesxi-securitygroup.id
  #group  = ibm_is_vpc.vpc.default_security_group
  direction = "outbound"
  remote    = "0.0.0.0/0"
#   tcp {
#     port_min = 1
#     port_max = 65535
#   }
 }

# create the ip prefix 1 and block associated with each zone
resource "ibm_is_vpc_address_prefix" "ip_prefix1" {
  name = "address-prefix-1"
  zone = "${var.region}-${var.zone_number}"
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.ip_block[0]
}

# create the ip prefix 2 and block associated with each zone
resource "ibm_is_vpc_address_prefix" "ip_prefix2" {
  name = "address-prefix-2"
  zone = "${var.region}-${var.zone_number}"
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.ip_block[1]
}

# create the ip prefix 3 and block associated with each zone
resource "ibm_is_vpc_address_prefix" "ip_prefix3" {
  name = "address-prefix-3"
  zone = "${var.region}-${var.zone_number}"
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.ip_block[2]
}

# create subnet 1 into the VPC, for each zone
resource "ibm_is_subnet" "subnet1" {
  depends_on = [
    ibm_is_vpc_address_prefix.ip_prefix1
  ]
  name                      = "subnet-1"
  vpc                       = ibm_is_vpc.vpc.id
  zone                      = "${var.region}-${var.zone_number}"
  ipv4_cidr_block           = var.ip_block[0]
}

# create subnet 2 into the VPC, for each zone
resource "ibm_is_subnet" "subnet2" {
  depends_on = [
    ibm_is_vpc_address_prefix.ip_prefix2
  ]
  name                      = "subnet-2"
  vpc                       = ibm_is_vpc.vpc.id
  zone                      = "${var.region}-${var.zone_number}"
  ipv4_cidr_block           = var.ip_block[1]
}

# create subnet 3 into the VPC, for each zone
resource "ibm_is_subnet" "subnet3" {
  depends_on = [
    ibm_is_vpc_address_prefix.ip_prefix3
  ]
  name                      = "subnet-3"
  vpc                       = ibm_is_vpc.vpc.id
  zone                      = "${var.region}-${var.zone_number}"
  ipv4_cidr_block           = var.ip_block[2]
}

resource "ibm_is_ssh_key" "sshpubkey" {
  name       = var.user-sshpubkeyname
  public_key = var.user-public-key
  resource_group = ibm_resource_group.rg.id
}
