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
