# Nested-ESXi
This is Nested ESXi project that will deploy 5 ESXi hosts with 4 PNICs, 3 diks, create two clusters (MGMT and Compute), add those hosts there, create new latest version of vDS (7.0 at the moment), move last two PNICs to vDS and add port-groups. 
Finally NSX-T Manager and two NSX-T Edges will be rolled out on a new infrastructure.

Workflows need to be executed in order starting with the first one.

cd Workflow 1
Place ks.cfg file to NFS server and adjust esxi-vars file to reflect your environment.

packer build -var-file=esxi-vars.json esxi.json

cd ../Workflow 2

Adjust terraform.tfvars and variables.tf files to reflect your environment. 

terraform init
terraform plan
terraform apply -auto-approve

cd ../Workflow 3

Adjust terraform.tfvars and variables.tf files to reflect your environment. 

terraform init
terraform plan
terraform apply -auto-approve

cd ../Workflow 4

adjust hosts.yml file and run the playbook

ansible-playbook deploy-nsx.yml
