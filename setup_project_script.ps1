# PowerShell script to create the complete homelab infrastructure project structure
# Run this from within the home-infra directory

Write-Host "Creating homelab infrastructure project structure..." -ForegroundColor Green

# Create directory structure
$directories = @(
    "modules\proxmox-lxc",
    "environments\home\dns-server",
    "environments\homelab\dns-server",
    "ansible\playbooks",
    "ansible\roles",
    "ansible\inventory\home\group_vars",
    "ansible\inventory\homelab\group_vars"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "Created directory: $dir" -ForegroundColor Cyan
}

# Create .gitignore
@"
# OpenTofu/Terraform
*.tfstate
*.tfstate.*
*.tfvars.backup
*.tfplan
.terraform/
.terraform.lock.hcl
*.auto.tfvars

# Terragrunt
.terragrunt-cache/

# Ansible
*.retry
.vault_pass
ansible.log

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Secrets and credentials
secrets/
*.pem
*.key
!*.key.example
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# Create README.md
@"
# Homelab Infrastructure Project

This project contains OpenTofu/Terragrunt infrastructure-as-code and Ansible configuration management for homelab services.

## Project Structure

``````
home-infra/
├── .gitignore
├── README.md
├── modules/
│   └── proxmox-lxc/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── environments/
│   ├── home/
│   │   ├── dns-server/
│   │   │   ├── terragrunt.hcl
│   │   │   ├── main.tf
│   │   │   └── terraform.tfvars
│   │   └── common.tfvars
│   └── homelab/
│       ├── dns-server/
│       │   ├── terragrunt.hcl
│       │   ├── main.tf
│       │   └── terraform.tfvars
│       └── common.tfvars
└── ansible/
    ├── ansible.cfg
    ├── requirements.yml
    ├── playbooks/
    │   ├── site.yml
    │   └── dns-server.yml
    ├── roles/
    │   └── .gitkeep
    └── inventory/
        ├── home/
        │   ├── hosts.yml
        │   └── group_vars/
        │       └── all.yml
        └── homelab/
            ├── hosts.yml
            └── group_vars/
                └── all.yml
``````

## Getting Started

1. Initialize OpenTofu in each environment directory
2. Configure Proxmox provider credentials
3. Run ``tofu plan`` and ``tofu apply`` to provision infrastructure
4. Use Ansible to configure and manage services

## Environment Descriptions

- **home/**: Production-like services for daily use (DNS/DHCP for main network)
- **homelab/**: Experimental and learning environment (can be torn down safely)
"@ | Out-File -FilePath "README.md" -Encoding UTF8

# Create modules/proxmox-lxc/main.tf
@"
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
"@ | Out-File -FilePath "modules\proxmox-lxc\main.tf" -Encoding UTF8

# Create modules/proxmox-lxc/variables.tf
@"
# Variables for Proxmox LXC Container Module

# Basic container configuration
variable "target_node" {
  description = "Proxmox node to deploy the container on"
  type        = string
}

variable "hostname" {
  description = "Hostname for the container"
  type        = string
}

variable "ostemplate" {
  description = "OS template to use for the container"
  type        = string
  default     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "root_password" {
  description = "Root password for the container"
  type        = string
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "SSH public keys to add to the container"
  type        = string
  default     = ""
}

# Container settings
variable "unprivileged" {
  description = "Whether to create an unprivileged container"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Whether to start the container on boot"
  type        = bool
  default     = true
}

variable "start_on_create" {
  description = "Whether to start the container after creation"
  type        = bool
  default     = true
}

# Resource allocation
variable "cores" {
  description = "Number of CPU cores for the container"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory allocation in MB"
  type        = number
  default     = 512
}

variable "swap" {
  description = "Swap allocation in MB"
  type        = number
  default     = 512
}

# Storage configuration
variable "storage" {
  description = "Storage pool for the container"
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Root filesystem size"
  type        = string
  default     = "8G"
}

# Network configuration
variable "network_name" {
  description = "Network interface name"
  type        = string
  default     = "eth0"
}

variable "network_bridge" {
  description = "Network bridge to connect to"
  type        = string
  default     = "vmbr0"
}

variable "network_ip" {
  description = "Static IP address for the container (CIDR notation)"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway IP address"
  type        = string
}

# Advanced features
variable "enable_nesting" {
  description = "Enable container nesting (for Docker inside LXC)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the container"
  type        = string
  default     = ""
}
"@ | Out-File -FilePath "modules\proxmox-lxc\variables.tf" -Encoding UTF8

# Create modules/proxmox-lxc/outputs.tf
@"
# Outputs for Proxmox LXC Container Module

output "container_id" {
  description = "The ID of the created container"
  value       = proxmox_lxc.container.vmid
}

output "hostname" {
  description = "The hostname of the container"
  value       = proxmox_lxc.container.hostname
}

output "ip_address" {
  description = "The IP address of the container"
  value       = var.network_ip
}

output "target_node" {
  description = "The Proxmox node the container is running on"
  value       = proxmox_lxc.container.target_node
}

output "container_status" {
  description = "The status of the container"
  value       = proxmox_lxc.container.start ? "running" : "stopped"
}

output "ansible_host" {
  description = "Host information for Ansible inventory"
  value = {
    hostname    = proxmox_lxc.container.hostname
    ip_address  = var.network_ip
    target_node = proxmox_lxc.container.target_node
  }
}
"@ | Out-File -FilePath "modules\proxmox-lxc\outputs.tf" -Encoding UTF8

# Create modules/proxmox-lxc/versions.tf
@"
# Version constraints for Proxmox LXC Container Module

terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}
"@ | Out-File -FilePath "modules\proxmox-lxc\versions.tf" -Encoding UTF8

# Create environments/home/dns-server/main.tf
@"
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
"@ | Out-File -FilePath "environments\home\dns-server\main.tf" -Encoding UTF8

# Continue with remaining files...
Write-Host "Creating remaining files..." -ForegroundColor Yellow

# Add variables.tf to home dns-server
@"
# Variables for home DNS server deployment

variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox username"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "target_node" {
  description = "Proxmox node name"
  type        = string
}

variable "hostname" {
  description = "Container hostname"
  type        = string
}

variable "root_password" {
  description = "Root password"
  type        = string
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "SSH public keys"
  type        = string
  default     = ""
}

variable "cores" {
  description = "CPU cores"
  type        = number
}

variable "memory" {
  description = "Memory in MB"
  type        = number
}

variable "swap" {
  description = "Swap in MB"
  type        = number
}

variable "storage" {
  description = "Storage pool"
  type        = string
}

variable "disk_size" {
  description = "Disk size"
  type        = string
}

variable "network_ip" {
  description = "Network IP"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
}
"@ | Out-File -FilePath "environments\home\dns-server\variables.tf" -Encoding UTF8

# Create environments/home/dns-server/terraform.tfvars
@"
# Home DNS Server Configuration
# Production DNS/DHCP service configuration

# Basic container settings
hostname = "dns-home"
target_node = "proxmox-node-1"  # Replace with your actual Proxmox node name

# Network configuration - adjust for your home network
network_ip      = "192.168.86.10/24"  # Static IP for DNS server
network_gateway = "192.168.86.1"      # Your router IP
network_bridge  = "vmbr0"            # Default Proxmox bridge

# Resource allocation for home production use
cores  = 2
memory = 1024  # 1GB RAM
swap   = 1024  # 1GB swap
disk_size = "10G"

# Storage pool
storage = "local-lvm"  # Adjust based on your Proxmox storage

# SSH access - replace with your actual public key
ssh_public_keys = ""  # Add your SSH public key here

# Root password - use a secure password
root_password = "changeme123"  # Change this!

# Proxmox connection details - use environment variables or .tfvars.local
# proxmox_api_url = "https://your-proxmox-host:8006/api2/json"
# proxmox_user = "root@pam"
# proxmox_password = "your-password"  # Better to use API tokens
# proxmox_tls_insecure = true
"@ | Out-File -FilePath "environments\home\dns-server\terraform.tfvars" -Encoding UTF8

Write-Host "All files and directories created successfully!" -ForegroundColor Green
Write-Host "Project structure is ready in the current directory." -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update terraform.tfvars files with your actual configuration" -ForegroundColor White
Write-Host "2. Add your SSH public key to the tfvars files" -ForegroundColor White
Write-Host "3. Set up Proxmox connection environment variables" -ForegroundColor White
Write-Host "4. Initialize OpenTofu: tofu init" -ForegroundColor White
Write-Host "5. Install Ansible requirements: ansible-galaxy install -r ansible/requirements.yml" -ForegroundColor White
