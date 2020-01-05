resource "proxmox_vm_qemu" "generic-vm" {
  count = length(var.ips)

  name = "${var.name_prefix}-${count.index}"
  desc = "generic terraform-created vm"
  target_node = var.target_node

  clone = var.template_name

  agent = 1
  os_type = "cloud-init"
  cores = var.cores
  sockets = "1"
  vcpus = "0"
  cpu = "host"
  scsihw = "virtio-scsi-pci"
  memory = var.memory
  bootdisk = "scsi0"

  disk {
    id = 0
    type = "scsi"
    storage = var.storage_pool
    size = var.storage_size
  }

  network {
    id = 0
    model = "virtio"
    bridge = var.bridge
  }

  ipconfig0 = "ip=${var.ips[count.index]},gw=${var.gateway}"

  ssh_user = var.ssh_user
  sshkeys = var.sshkeys

	lifecycle {
    ignore_changes = [
      network
    ]
  }
}

