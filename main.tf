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
 resource "ibm_is_security_group" "security_group_inst" {
   name = var.security_group
   vpc  = ibm_is_vpc.vpc.id
   resource_group = ibm_resource_group.rg.id
 }

# Create a first Security Group Rule inbound for http
resource "ibm_is_security_group_rule" "ibm_is_security_group_rule-inbound-http" {
  group     = ibm_is_security_group.security_group_inst.id
  direction = "inbound"
  #remote = "any"
  #remote    = "0.0.0.0/0"
  tcp {
     port_min = 80
     port_max = 80
   }
}

# Create a second Security Group Rule inbound for https
resource "ibm_is_security_group_rule" "ibm_is_security_group_rule-inbound-https" {
  group     = ibm_is_security_group.security_group_inst.id
  direction = "inbound"
  #remote = "any"
  #remote    = "0.0.0.0/0"
  tcp {
     port_min = 443
     port_max = 443
   }
}

# Create a second Security Group Rule inbound for ssh
resource "ibm_is_security_group_rule" "ibm_is_security_group_rule-inbound-ssh" {
  group     = ibm_is_security_group.security_group_inst.id
  direction = "inbound"
  #remote = "any"
  #remote    = "0.0.0.0/0"
  tcp {
     port_min = 22
     port_max = 22
   }
}

# Create a second Security Group Rule inbound for all tcp
resource "ibm_is_security_group_rule" "ibm_is_security_group_rule-inbound-alltcp" {
  group     = ibm_is_security_group.security_group_inst.id
  direction = "outbound"
  #remote = "any"
  #remote    = "0.0.0.0/0"
  tcp {
     port_min = 1
     port_max = 65535
   }
}

# Create a second Security Group Rule inbound for all udp
resource "ibm_is_security_group_rule" "ibm_is_security_group_rule-inbound-alludp" {
  group     = ibm_is_security_group.security_group_inst.id
  direction = "outbound"
  #remote = "any"
  #remote    = "0.0.0.0/0"
  udp {
     port_min = 1
     port_max = 65535
   }
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

resource "ibm_is_floating_ip" "fip1" {
   name   = "ha-proxi-external-fip1"
   zone    = "eu-es-2"
     }

resource "ibm_is_instance" "ha-proxi-external-mad2-inst" {
  name    = "ha-proxi-external-mad2"
  image   = "r050-19e869f7-3d76-4fd4-8f71-91595a7b44a8"
  profile = "bx2-4x16"
  #metadata_service_enabled  = false
  primary_network_interface {
    name = "ha-proxi-external-mad2-sn2"
    subnet = ibm_is_subnet.subnet2.id
    #primary_ip{
    #  address = "192.168.22.240"
    #}
    security_groups = [ ibm_is_security_group.security_group_inst.id ]
    allow_ip_spoofing = false
    # primary_ipv4_address = "192.168.22.240"  // will be deprecated. Use primary_ip.[0].address
  }
  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.region}-${var.zone_number}"
  keys = [ibm_is_ssh_key.sshpubkey.id]
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_is_instance_network_interface_floating_ip" "ha-proxi-external-mad2-inst-float" {
  instance          = ibm_is_instance.ha-proxi-external-mad2-inst.id
  network_interface = ibm_is_instance.ha-proxi-external-mad2-inst.primary_network_interface[0].id
  floating_ip       = ibm_is_floating_ip.fip1.id
  }
  


#data "ibm_is_instance_disk" "disk0" {
#  instance = data.ibm_is_instance.disk0.id
#  disk     = data.ibm_is_instance.disk0.0.id
#  size     = 150
#}