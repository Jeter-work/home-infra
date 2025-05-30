# Proxmox LXC Container Module
# Creates and configures LXC containers on Proxmox VE

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

# LXC Container Resource
resource "proxmox_lxc" "container" {
  target_node  = var.target_node
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  password     = var.root_password
  unprivileged = var.unprivileged
  onboot       = var.onboot
  start        = var.start_on_create

  # SSH key configuration
  ssh_public_keys = var.ssh_public_keys

  # Resource allocation
  cores  = var.cores
  memory = var.memory
  swap   = var.swap

  # Root filesystem
  rootfs {
    storage = var.storage
    size    = var.disk_size
  }

  # Network configuration
  network {
    name   = var.network_name
    bridge = var.network_bridge
    ip     = var.network_ip
    gw     = var.network_gateway
  }

  # Features for network services
  features {
    nesting = var.enable_nesting
  }

  # Tags for organization
  tags = var.tags

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      # Ignore changes to password after creation
      password,
    ]
  }
}
