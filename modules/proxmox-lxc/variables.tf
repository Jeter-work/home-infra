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
