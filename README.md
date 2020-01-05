# k3s on Proxmox
Based on the work from 
https://pawalt.github.io/posts/2019/07/automating-k3s-deployment-on-proxmox/

# Prerequisites
## Install Terraform
* Just download Terraform from the downloads page and drop it somewhere in your $PATH
## Install the Terraform Proxmox provider
* Use the go install command found in the README
* Drop the binaries into ~/.terraform.d/plugins/
## Have a Proxmox host
## Install Ansible

# Building a cloud-init Ubuntu template
On your proxmox server execute the following
* Download cloud-init image 
`wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img`
* Export your Storage pool that should be used for the images
`export STORAGE_POOL=limages`
* Create a VM to be used as template
`qm create 8000 --memory 2048 --net0 virtio,bridge=vmbr0`
* Due to a bug rename image file to qcow2
`mv bionic-server-cloudimg-amd64.img bionic-server-cloudimg-amd64.qcow2`
* Import image
`qm importdisk 8000 bionic-server-cloudimg-amd64.qcow2 $STORAGE_POOL`
* Set disk image for vm
`qm set 8000 --scsihw virtio-scsi-pci --scsi0 $STORAGE_POOL:vm-8000-disk-0`
if not using zfs this might look like this. 
`qm set 8000 --scsihw virtio-scsi-pci --scsi0 $STORAGE_POOL:8000/vm-8000-disk-0.raw`
* Set a name for the vm
`qm set 8000 --name ubuntu-ci`
* Add the cloudinit drive
`qm set 8000 --ide2 $STORAGE_POOL:cloudinit`
* Set the bootdisk to our image
`qm set 8000 --boot c --bootdisk scsi0`
* Activate a serial console
`qm set 8000 --serial0 socket --vga serial0`
* Finally, make this a template 
`qm template 8000`
At this point we have a template we can use as base and you can confirm that it is functional by creating a new 'full clone' through the 'clone' functionality in proxmox.

# Deploying the VMs through terraform
Follow the instructions for "Deploying the VMs" at 
https://pawalt.github.io/posts/2019/07/automating-k3s-deployment-on-proxmox/
* Clone this repo instead https://github.com/tott/proxmox-k3s
* Change directory
`cd proxmox-k3s/proxmox-tf/prod`
* Edit the main.tf to match your needs
* Export access credentials for your proxmox api.
  $ export PM_API_URL="https://<node_ip>:8006/api2/json"<Paste>
  $ export PM_USER=root@pam
  $ export PM_PASS=<your_pass_here>
You can also alter provision.sh to your need and simply execute:
`source ./provision.sh`
when you need the exported variables.
* Execute terraform
  $ terraform init
  $ terraform plan
  $ terraform apply

# Remaining steps as outlined in https://pawalt.github.io/posts/2019/07/automating-k3s-deployment-on-proxmox/

