resource "proxmox_virtual_environment_vm" "exam_vms" {
  for_each = var.vm_configs

  name        = each.key
  node_name   = var.proxmox_node
  vm_id       = each.value.vm_id
  pool_id     = var.pool_id
  description = "DevOps practical exam VM - ${each.key}"

  clone {
    vm_id = var.template_id
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.storage
    size         = each.value.disk
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    user_account {
      username = var.vm_username
      password = var.vm_password
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  agent {
    enabled = true
  }

  started = true
}
