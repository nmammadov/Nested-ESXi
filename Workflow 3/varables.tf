
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
