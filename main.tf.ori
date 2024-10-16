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


resource "ibm_is_ssh_key" "sshpubkey" {
  name       = var.user-sshpubkeyname
  public_key = var.user-public-key
  resource_group = ibm_resource_group.rg.id
}


resource "ibm_is_floating_ip" "fip1" {
   name   = "ocp-svc-fip1"
   zone    = "eu-de-2"
     }

resource "ibm_is_instance" "ocp-svc-inst" {
  name    = "ocp-svc"
  image   = "r010-4562c7db-9b67-42dd-b39c-9fbca4a2c27f"
  profile = "bx2-2x8"
  #metadata_service_enabled  = false
  primary_network_interface {
    name = "ocp-svc-sn1"
    subnet = ibm_is_subnet.subnet1.id
    primary_ip{
      address = "192.168.22.240"
    }
    security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
    allow_ip_spoofing = false
    # primary_ipv4_address = "192.168.22.240"  // will be deprecated. Use primary_ip.[0].address
  }
  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.region}-${var.zone_number}"
  keys = [ibm_is_ssh_key.sshpubkey.id]
  resource_group = ibm_resource_group.rg.id

  network_interfaces {
   name   = "ocp-svc-sn2"
   subnet = ibm_is_subnet.subnet2.id
   allow_ip_spoofing = false
   security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
   }
}

resource "ibm_is_instance_network_interface_floating_ip" "ocp-svc-inst-float" {
  instance          = ibm_is_instance.ocp-svc-inst.id
  network_interface = ibm_is_instance.ocp-svc-inst.network_interfaces[0].id
  floating_ip       = ibm_is_floating_ip.fip1.id
  }
  

resource "ibm_is_floating_ip" "fip2" {
  name    = "fip2"
  #zone    = "${var.region}-${var.zone_number}"
  target = ibm_is_bare_metal_server.bm-esxi.primary_network_interface[0].id
}





# BARE METAL CREATION
resource "ibm_is_bare_metal_server" "bm-esxi" {
  profile = "bx2d-metal-96x384"
  name    = "bm-esxi-ocp"
  image   = "r010-21ebb65e-611a-46c9-8532-70248fc2315e"
  zone    = "${var.region}-${var.zone_number}"
  keys    = [ibm_is_ssh_key.sshpubkey.id]
  primary_network_interface {
    subnet     = ibm_is_subnet.subnet2.id
    allowed_vlans  = [1,2]
    enable_infrastructure_nat = true
  primary_ip {
      #primary_ip.[0].address = "192.168.0.101"
      address = "192.168.0.101"
    }
    security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
}
  vpc   = ibm_is_vpc.vpc.id
  resource_group = ibm_resource_group.rg.id
}


resource "ibm_is_bare_metal_server_network_interface" "bms_bootstrap_nic-vlan1" {
  name = "ocp-bootstrap"
  bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
  subnet      = ibm_is_subnet.subnet1.id
  vlan     = 1
  primary_ip {
    auto_delete = true
    address     = "192.168.22.200"
  }
  security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
}


resource "ibm_is_bare_metal_server_network_interface" "bms_ocp-cp1-nic-vlan1" {
  name        = "ocp-cp1"
  bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
  subnet      = ibm_is_subnet.subnet1.id
  vlan     = 1
  primary_ip {
    auto_delete = true
    address     = "192.168.22.201"
  }
  security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
}


resource "ibm_is_bare_metal_server_network_interface" "bms_ocp-cp2-nic-vlan1" {
  name        = "ocp-cp2"
  bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
  subnet      = ibm_is_subnet.subnet1.id
  vlan     = 1
  primary_ip {
    auto_delete = true
    address     = "192.168.22.202"
  }
  security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
}


resource "ibm_is_bare_metal_server_network_interface" "bms_ocp-cp3-nic_vlan1" {
   name        = "ocp-cp3"
   bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
   subnet      = ibm_is_subnet.subnet1.id
   vlan     = 1
   primary_ip {
     auto_delete = true
     address     = "192.168.22.203"
  }
  security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
}


# resource "ibm_is_bare_metal_server_network_interface" "bms_ocp-svc-sn1-nic_vlan1" {
#    name        = "ocp-svc-sn1"
#    bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
#    subnet      = ibm_is_subnet.subnet1.id
#    vlan     = 1
#    primary_ip {
#      auto_delete = true
#      address     = "192.168.22.240"
#   }
# }



# resource "ibm_is_bare_metal_server_network_interface" "bms_ocp-svc-sn2-nic_vlan2" {
#    name        = "ocp-svc-sn2"
#    bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
#    subnet      = ibm_is_subnet.subnet2.id
#    vlan     = 2
#    primary_ip {
#      auto_delete = true
#      address     = "192.168.0.240"
#   }
# }


resource "ibm_is_bare_metal_server_network_interface" "bms_ocp-w-1-nic_vlan1" {
   name        = "ocp-w-1"
   bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
   subnet      = ibm_is_subnet.subnet1.id
   vlan     = 1
   primary_ip {
     auto_delete = true
     address     = "192.168.22.211"
  }
  security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
}


resource "ibm_is_bare_metal_server_network_interface" "bms_ocp-w-2-nic_vlan1" {
   name        = "ocp-w-2"
   bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
   subnet      = ibm_is_subnet.subnet1.id
   vlan     = 1
   primary_ip {
     auto_delete = true
     address     = "192.168.22.212"
  }
  security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
}


resource "ibm_is_bare_metal_server_network_interface" "bms_ocp-w-3-nic_vlan1" {
   name        = "ocp-w-3"
   bare_metal_server = ibm_is_bare_metal_server.bm-esxi.id
   subnet      = ibm_is_subnet.subnet1.id
   vlan     = 1
   primary_ip {
     auto_delete = true
     address     = "192.168.22.213"
  }
  security_groups = [ ibm_is_security_group.ocpbmesxi-securitygroup.id ]
}



