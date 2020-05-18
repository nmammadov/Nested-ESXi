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


# Indicate name of VMs and their quantity. By default it will create 5 nested esxi hosts with names below
variable "vm_names" {
default = {
  "vesxi101" = 1
  "vesxi102" = 2
  "vesxi103" = 3
  "vesxi104" = 4
  "vesxi105" = 5
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

  # By default it will add 4 interfaces on the host. 1st will be connected to mgmt network, three others will be trunked
  
  network_interface {
    network_id   = data.vsphere_network.target_network_mgmt.id
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
  network_interface {
    network_id   = data.vsphere_network.target_network.id
    adapter_type = data.vsphere_virtual_machine.source_template.network_interface_types[0]
  }
 
  disk {
    label            = "disk0"
    size             = 40
    thin_provisioned = data.vsphere_virtual_machine.source_template.disks[0].thin_provisioned
  }
  
  # Adding two more disks for VSAN
  
  disk {
    label            = "disk1"
    size             = 111
    thin_provisioned = data.vsphere_virtual_machine.source_template.disks[0].thin_provisioned
    unit_number      = 1
  }
  disk {
    label            = "disk2"
    size             = 222
    thin_provisioned = data.vsphere_virtual_machine.source_template.disks[0].thin_provisioned
    unit_number      = 2
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.source_template.id
    timeout = 120     
  
  }

 # Changing settings to make static IP address for vmk0, adding second nic to standard vSwitch0, adjusting NTP and DNS values.
  
provisioner "remote-exec" {
    inline = ["esxcli system hostname set -H=${each.key} -d=home.lab",
    "esxcli network ip dns server add --server=192.168.156.11",
    "echo server 192.168.156.11 > /etc/ntp.conf && /etc/init.d/ntpd start",
    "esxcli network vswitch standard uplink add --uplink-name=vmnic1 --vswitch-name=vSwitch0",
    "esxcli network ip interface ipv4 set -i vmk0 -t static -g 172.23.10.252 -I 172.23.10.10${each.value} -N 255.255.255.0 ",
    ]
}

connection  {
      user           = var.guest_user
      password       = var.guest_password
      timeout = 15
      host  = self.guest_ip_addresses[0]
    }
   }


  
