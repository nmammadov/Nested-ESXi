provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "target_dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "target_datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.target_dc.id
}

data "vsphere_compute_cluster" "target_cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.target_dc.id
}

data "vsphere_network" "target_network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.target_dc.id
}

data "vsphere_network" "target_network_mgmt" {
  name          = var.vsphere_network_mgmt
  datacenter_id = data.vsphere_datacenter.target_dc.id
}


data "vsphere_virtual_machine" "source_template" {
  name          = var.guest_template
  datacenter_id = data.vsphere_datacenter.target_dc.id
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

resource "vsphere_virtual_machine" "vesxi" {
  for_each = var.vm_names
  name = each.key
  datastore_id     = data.vsphere_datastore.target_datastore.id
  folder           = var.vsphere_folder
  resource_pool_id = data.vsphere_compute_cluster.target_cluster.resource_pool_id
  num_cpus = var.guest_vcpu
  memory   = var.guest_memory
  nested_hv_enabled = "true"
  wait_for_guest_net_routable ="false"
  guest_id = data.vsphere_virtual_machine.source_template.guest_id
  wait_for_guest_net_timeout = 35
  wait_for_guest_ip_timeout = 35
  scsi_type = data.vsphere_virtual_machine.source_template.scsi_type


  # First interface will be in MGMT port group
  network_interface {
    network_id   = data.vsphere_network.target_network_mgmt.id
    adapter_type = data.vsphere_virtual_machine.source_template.network_interface_types[0]
    
  }
  
  # Other 3 vmnics will be added in a Trunk port group

  network_interface {
    network_id   = data.vsphere_network.target_network.id
    adapter_type = data.vsphere_virtual_machine.source_template.network_interface_types[0]
  }
  network_interface {
    network_id   = data.vsphere_network.target_network.id
    adapter_type = data.vsphere_virtual_machine.source_template.network_interface_types[0]
  }
  network_interface {
    network_id   = data.vsphere_network.target_network.id
    adapter_type = data.vsphere_virtual_machine.source_template.network_interface_types[0]
  }
 
  disk {
    label            = "disk0"
    size             = var.guest_disk0_size
    thin_provisioned = true
  }
  
  disk {
    label            = "disk1"
    size             = var.guest_disk1_size
    thin_provisioned = true
    unit_number      = 1
  }
  disk {
    label            = "disk2"
    size             = var.guest_disk2_size
    thin_provisioned = true
    unit_number      = 2
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.source_template.id
    timeout = 120     
  
  }

provisioner "remote-exec" {
    inline = ["esxcli system hostname set -H=${each.key} -d=${var.guest_domain}",
    "esxcli network ip dns server add --server=${var.guest_dns}",
    "echo server ${var.guest_ntp} > /etc/ntp.conf && /etc/init.d/ntpd start",
    "esxcli network vswitch standard uplink add --uplink-name=vmnic1 --vswitch-name=vSwitch0",
    "esxcli network ip interface ipv4 set -i vmk0 -t static -g ${var.guest_gateway} -I ${var.guest_start_ip}${each.value} -N ${var.guest_netmask} ",
    ]
}

connection  {
      user           = var.guest_user
      password       = var.guest_password
      timeout = 15
      host  = self.guest_ip_addresses[0]
    }  

   }


  
