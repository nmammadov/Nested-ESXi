
variable "vsphere_server" {
  description = "vCenter FQDN/IP "
}

variable "vsphere_user" {
  description = "vSphere username"
  default     = "administrator@vsphere.local"
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
  description = "Porgroup to which the virtual machine will be connected."
}


variable "guest_template" {
  description = "The source virtual machine or template to clone from."
}

variable "guest_vcpu" {
  description = "The number of virtual processors to assign to this virtual machine. Default: 1."
  default     = "1"
}

variable "guest_memory" {
  description = "The size of the virtual machine's memory, in MB. Default: 1024 (1 GB)."
  default     = "1024"
}

variable "guest_user" {
  description = "Username for guest VM."
}
variable "guest_password" {
  description = "Password for guest user."
}