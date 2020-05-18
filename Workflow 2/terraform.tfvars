# Provider
vsphere_user = "administrator@lab.home"
vsphere_password = "VMware1!VMware1!"
vsphere_server = "vcsa01.home.lab"

# Infrastructure
vsphere_datacenter = "SanJose"
vsphere_cluster = "Physical"
vsphere_datastore = "NFS-3"
vsphere_folder = "/Terraform"
vsphere_network = "VSS-Trunk"
vsphere_network_mgmt = "mgmt-vss"

# Guest
guest_template = "esxi-nested"
guest_vcpu = "8"
guest_memory = "262144"
guest_user = "root"
guest_password = "VMware1!"
# Disks for the guest. Disk0 is main drive, disk1 and disk2 for VSAN
guest_disk0_size = "40"
guest_disk1_size = "111"
guest_disk2_size = "222"
guest_dns = "192.168.156.11"
guest_ntp = "192.168.156.11"
guest_domain = "home.lab"
# Guest start_ip format is the following. If ip address needs to be 172.23.10.101, then make guest_ip = 172.23.10.10. Last character will be added by the script later.
guest_start_ip = "172.23.10.10"
guest_netmask = "255.255.255.0"
guest_gateway = "172.23.10.252"
