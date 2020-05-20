# Nested-ESXi
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
