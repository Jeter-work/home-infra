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
