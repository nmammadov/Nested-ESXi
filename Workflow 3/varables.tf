
variable "vsphere_server" {
  description = "vCenter FQDN/IP "
}

variable "vsphere_user" {
  description = "vSphere username"
}

variable "vsphere_password" {
  description = "vSphere password"
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter"
}

variable "mgmt_cluster" {
  description = "MGMT cluster name"
}

variable "compute_cluster" {
  description = "Compute cluster name"
}

# Indicate all hosts to be added to vCenter. FQDN or IP 

variable "all_hosts" {
  default =["vesxi101.home.lab","vesxi102.home.lab","vesxi103.home.lab","vesxi104.home.lab","vesxi105.home.lab"]
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

variable "esxi_user" {
  description = "esxi root user"
}

variable "esxi_password" {
  description = "esxi root password"
}
variable "vds_name" {
  description = "VDS Name"
}
variable "vds_mtu" {
  description = "VDS MTU"
}
variable "vlan_range_min" {
  description = "VLAN Starting Range"
}
variable "vlan_range_max" {
  description = "VLAN Ending Range"
}
