provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

# Creating new datacenter using name defined in variables file.

resource "vsphere_datacenter" "target_dc" {
  name = var.vsphere_datacenter
}

# This is Python script that will get ESXi hosts thumbprints.
# Passing username,password and list of hosts to connect as variables. 

data "external" "get_thumbprint" {
   program = ["python", "Esxi-connect.py"]

  query = {
    username = var.esxi_user
    password = var.esxi_password
    hosts = "${join(" ",var.all_hosts)}"
  }
}

# Creating Cluster for Managemnt 
# Note this depends on previous datacenter object to be created first.

resource "vsphere_compute_cluster" "c1" {
  name            = var.mgmt_cluster
  datacenter_id   = vsphere_datacenter.target_dc.moid
  depends_on = [vsphere_datacenter.target_dc,]
}

# Creating Cluster for Compute 
# Note this depends on previous datacenter object to be created first.

resource "vsphere_compute_cluster" "c2" {
  name            = var.compute_cluster
  datacenter_id   = vsphere_datacenter.target_dc.moid
  depends_on = [vsphere_datacenter.target_dc,]

}

# Adding hosts to management cluster. By default two hosts will be added.
# This depends on previously created Management cluster

resource "vsphere_host" "h1" {
  for_each = var.host_names_mgmt
  hostname = each.key
  username = var.esxi_user
  password = var.esxi_password
  thumbprint = data.external.get_thumbprint.result["${each.key}"]
  cluster = vsphere_compute_cluster.c1.id
  depends_on = [vsphere_compute_cluster.c1]
}

# Adding hosts to compute cluster. By default three hosts will be added.
# This depends on previously created Compute cluster

resource "vsphere_host" "h2" {
  for_each = var.host_names_comp
  hostname = each.key
  username = var.esxi_user
  password = var.esxi_password
  thumbprint = data.external.get_thumbprint.result["${each.key}"]
  cluster = vsphere_compute_cluster.c2.id
  depends_on = [vsphere_compute_cluster.c2]
}

# Creating latest version of Distributed Switch ,setting MTU. By default it inlcudes 2 uplinks and adds all five hosts


resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vds_name
  datacenter_id = vsphere_datacenter.target_dc.moid
  max_mtu = var.vds_mtu
    depends_on = [vsphere_host.h1,vsphere_host.h2]


  uplinks         = ["uplink1", "uplink2"]
  
  host {
    host_system_id = vsphere_host.h1["vesxi101.home.lab"].id
    devices        = var.network_interfaces
  }
  
   host {
    host_system_id = vsphere_host.h1["vesxi102.home.lab"].id
    devices        = var.network_interfaces
  }

 host {
    host_system_id = vsphere_host.h2["vesxi103.home.lab"].id
    devices        = var.network_interfaces
 }

 host {
    host_system_id = vsphere_host.h2["vesxi104.home.lab"].id
    devices        = var.network_interfaces

    }

 host {
    host_system_id = vsphere_host.h2["vesxi105.home.lab"].id
    devices        = var.network_interfaces
      }

}

# Creating distributed port groups

resource "vsphere_distributed_port_group" "pg1" {
  for_each = var.pg
  name                            = each.key
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id

  vlan_id = each.value
}

# Creating trunk port group

resource "vsphere_distributed_port_group" "pg2" {
  name                            = "dvs-trunk"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id

  vlan_range {
    min_vlan = var.vlan_range_min
    max_vlan = var.vlan_range_max
  }
}
