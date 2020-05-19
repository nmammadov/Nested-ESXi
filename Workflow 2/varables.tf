
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

variable "vsphere_cluster" {
  description = "vSphere cluster"
}

variable "vsphere_datastore" {
  description = "Datastore where VMs will be deployed."
}

variable "vsphere_folder" {
  description = "vSphere folder to store VMs"
}

variable "vsphere_network" {
  description = "Porgroup to which the virtual machine will be connected."
}

variable "vsphere_network_mgmt" {
  description = "Porgroup to which the virtual machine management will be connected."
}

# Indicate VM names and value of IP address last octet . By default it will create 5 VMs 

variable "vm_names" {
default = {
  "vesxi101" = 101
  "vesxi102" = 102
  "vesxi103" = 103
  "vesxi104" = 104
  "vesxi105" = 105
  }
}


variable "guest_template" {
  description = "The source template to clone from."
}

variable "guest_vcpu" {
  description = "Guest VM vCPU amount"
}

variable "guest_memory" {
  description = "Guest VM Memory size"
}

variable "guest_user" {
  description = "Username for guest VM."
}
variable "guest_password" {
  description = "Password for guest user."
}

variable "guest_disk0_size" {
  description = "Size of first disk to be added."   
}
variable "guest_disk1_size" {
  description = "Size of second disk to be added. Needed for VSAN"   
}
variable "guest_disk2_size" {
  description = "Size of third disk to be added. Needed for VSAN"   
}

variable "guest_dns" {
  description = "DNS server for the guest."
}
variable "guest_ntp" {
  description = "NTP server for the guest."  
}
variable "guest_domain" {
  description = "Domain for the guest."  
}
variable "guest_start_ip" {
  description = "Starting IP address for the guest vmk0 interface"  
}
variable "guest_netmask" {
  description = "Netmask for the guest vmk0 interface"   
}
variable "guest_gateway" {
  description = "Gateway for the guest vmk0 interface"   
}
