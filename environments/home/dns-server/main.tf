# Home DNS Server Infrastructure
# Production DNS/DHCP services for main home network

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }

  # Configure remote state (adjust backend as needed)
  backend "local" {
    path = "./terraform.tfstate"
  }
}

# Proxmox provider configuration
provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = var.proxmox_tls_insecure
}

# DNS Server Container
module "dns_server" {
  source = "../../../modules/proxmox-lxc"

  # Basic configuration
  target_node    = var.target_node
  hostname       = var.hostname
  root_password  = var.root_password
  ssh_public_keys = var.ssh_public_keys

  # Resource allocation for production use
  cores  = var.cores
  memory = var.memory
  swap   = var.swap

  # Storage configuration
  storage   = var.storage
  disk_size = var.disk_size

  # Network configuration
  network_ip      = var.network_ip
  network_gateway = var.network_gateway
  network_bridge  = var.network_bridge

  # Production settings
  onboot           = true
  start_on_create  = true
  unprivileged     = true
  enable_nesting   = false

  # Tags for organization
  tags = "home,dns,production"
}
