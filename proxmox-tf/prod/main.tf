provider "proxmox" {
  pm_tls_insecure = true
}

module "k3s-cluster" {
  source = "../modules/generic-cluster"

  name_prefix = "k3s-node"
  ips = [
    "192.168.0.80/22",
    "192.168.0.81/22",
    "192.168.0.82/22",
    "192.168.0.83/22",
  ]

  sshkeys = file("~/.ssh/id_rsa.pub")
	ssh_user = "ubuntu"

  gateway = "192.168.0.1"
  bridge = "vmbr0"
  cores = 2
  memory = 2048
  storage_size = "32G"
  storage_pool = "limages"
  target_node = "discovery"
	template_name = "ubuntu-ci"
}
