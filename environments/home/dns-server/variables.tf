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
