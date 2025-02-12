###############################################################################
# Cloud provider used
#
# author: Frederik Aouizerats
# function: Cloud Architect
# email: frederik.aouizerats@ibm.com
###############################################################################

provider "ibm" {
    ibmcloud_api_key   = var.ibmcloud_api_key
    region = var.region
    }

