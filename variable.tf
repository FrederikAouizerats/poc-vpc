variable "ibmcloud_api_key" {
    description = " Your IBM Cloud API key"
    type = string
    default = null  
}

variable "region" {
    description = "The region where the VPC will be deployed"
    type = string
    default = "default"
}

variable "resources_group" {
    description = "the resource group name"
    type = string
    default = "default"
}

variable "name_vpc" {
    description = " The name of the vpc"
    type = string
    default = null
}

variable "security_group" {
    description = "the security group name"
    type = string
    default = "default"
}

variable "security_group-inbound_rule" {
    description = "the security group inbound default rule name"
    type = string
    default = "default"
}

variable "security_group-outbound_rule" {
    description = "the security group egress default rule name"
    type = string
    default = "default"
}

variable "zone_number"{
    description ="zone number handled by the VPC"
    default = 1
}

variable "ip_block" {
    description= " the ip block used by the prefixes and the subnets of the VPC, for commodity Subnets take full respectives Prefixes ranges"
    default=["10.243.0.0/24","10.243.64.0/24","10.243.128.0/24"]

}

variable "user-sshpubkeyname" {
    description = " user ssh key name "  
    default = null
}

variable "user-public-key" {
    description = " user public ssh key "  
    default = ""
}

variable "image-instance" {
    description = " instance image "  
    default = " vsi-image "
} 

variable "vsi-instance" {
    description = " vsi instance name "  
    default = " vsi-tertest "
}
