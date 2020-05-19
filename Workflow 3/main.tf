provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

# Indicate all hosts to be added to vCenter. FQDN or IP 
variable "all_hosts" {
  default =["vesxi101.home.lab","vesxi102.home.lab"]
}

# Indicate hosts in MGMT cluster. FQDN or IP
variable "host_names_mgmt" {
default = {
  "vesxi101.home.lab" = 1
  "vesxi102.home.lab" = 2
  }
}

# Indicate hosts in Compute cluster. FQDN or IP
variable "host_names_comp" {
default = {
  "vesxi103.home.lab" = 3
  "vesxi104.home.lab" = 4
  "vesxi105.home.lab" = 5
  }
}

# Indicate Distributed Port Group names and their respective VLAN IDs. 

variable "pg" {
  default = {
   "dvs-mgmt" = 10
   "dvs-vmotion" = 20
   "dvs-vsan" = 25
   "dvs-nsx-edge-uplink1" = 30
   "dvs-nsx-edge-uplink2" = 40
  }
}

# Indicate Network Interfaces of the hosts to be added to VDS . By default only vmnic2 & vmnic3 will be added.
variable "network_interfaces" {
    default = ["vmnic2","vmnic3"]
}



data "external" "abc" {
  program = ["python", "/Users/nmammadov/Playground/Terraform/Python/Esxi-connect.py"]
  query = {
    username = var.esxi_user
    password = var.esxi_password
    hosts = "${join(" ",var.all_hosts)}"
  }
}

data "vsphere_datacenter" "target_dc" {
  name = var.vsphere_datacenter
}

resource "vsphere_compute_cluster" "c1" {
  name            = var.mgmt_cluster
  datacenter_id   = data.vsphere_datacenter.target_dc.id
}

resource "vsphere_compute_cluster" "c2" {
  name            = var.compute_cluster
  datacenter_id   = data.vsphere_datacenter.target_dc.id
}


resource "vsphere_host" "h1" {
  for_each = var.host_names_mgmt
  hostname = each.key
  username = var.esxi_user
  password = var.esxi_password
  thumbprint = data.external.abc.result["${each.key}"]
  cluster = vsphere_compute_cluster.c1.id
  depends_on = [vsphere_compute_cluster.c1]
}

#resource "vsphere_host" "h2" {
#  for_each = var.host_names_comp
#  hostname = each.key
#  username = var.esxi_user
#  password = var.esxi_password
#  thumbprint = data.external.abc.result["${each.key}"]
#  thumbprint = data.external.abc.result["172.23.10.10${each.value}"]
#  cluster = vsphere_compute_cluster.c2.id
#  depends_on = [vsphere_compute_cluster.c2]
#}


resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vds_name
  datacenter_id = data.vsphere_datacenter.target_dc.id
  max_mtu = var.vds_mtu
  depends_on = [vsphere_host.h1]
  #depends_on = [vsphere_host.h1,vsphere_host.h2]


  uplinks         = ["uplink1", "uplink2"]
  
  host {
    host_system_id = vsphere_host.h1["vesxi101.home.lab"].id
    devices        = var.network_interfaces
  }
  
   host {
    host_system_id = vsphere_host.h1["vesxi102.home.lab"].id
    devices        = var.network_interfaces
  }

 #host {
 #   host_system_id = vsphere_host.h2["vesxi103.home.lab"].id
 #   devices        = var.network_interfaces

 #host {
 #   host_system_id = vsphere_host.h2["vesxi104.home.lab"].id
 #   devices        = var.network_interfaces

 #   }

 #host {
 #   host_system_id = vsphere_host.h2["vesxi105.home.lab"].id
 #   devices        = var.network_interfaces
 #     }

}

resource "vsphere_distributed_port_group" "pg1" {
  for_each = var.pg
  name                            = each.key
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id

  vlan_id = each.value
}

resource "vsphere_distributed_port_group" "pg2" {
  name                            = "dvs-trunk"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id

  vlan_range {
    min_vlan = 0
    max_vlan = 4094
  }
}
