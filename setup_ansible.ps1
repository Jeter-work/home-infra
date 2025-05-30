# PowerShell script to create all remaining Ansible configuration files
# Run this from within the home-infra directory AFTER running setup-project.ps1

Write-Host "Creating Ansible configuration files..." -ForegroundColor Green

# Create environments/home/dns-server/terragrunt.hcl
@"
# Terragrunt configuration for home DNS server
# Future Terragrunt migration configuration

# Include the root terragrunt.hcl configurations
include "root" {
  path = find_in_parent_folders()
}

# Include the environment-specific configurations
include "env" {
  path = find_in_parent_folders("env.hcl")
}

# Terraform source module
terraform {
  source = "../../../modules/proxmox-lxc"
}

# Input variables
inputs = {
  # Basic configuration
  hostname       = "dns-home"
  target_node    = "proxmox-node-1"
  
  # Network configuration
  network_ip      = "192.168.86.10/24"
  network_gateway = "192.168.86.1"
  network_bridge  = "vmbr0"
  
  # Resource allocation
  cores     = 2
  memory    = 1024
  swap      = 1024
  disk_size = "10G"
  storage   = "local-lvm"
  
  # Production settings
  onboot           = true
  start_on_create  = true
  unprivileged     = true
  enable_nesting   = false
  
  tags = "home,dns,production"
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = var.proxmox_tls_insecure
}
EOF
}
"@ | Out-File -FilePath "environments\home\dns-server\terragrunt.hcl" -Encoding UTF8

# Create homelab environment files
# Copy and modify home files for homelab
Copy-Item "environments\home\dns-server\main.tf" "environments\homelab\dns-server\main.tf"
Copy-Item "environments\home\dns-server\variables.tf" "environments\homelab\dns-server\variables.tf"

# Update homelab main.tf
@"
# Homelab DNS Server Infrastructure
# Experimental/testing DNS/DHCP services for homelab network

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

# DNS Server Container for homelab
module "dns_server" {
  source = "../../../modules/proxmox-lxc"

  # Basic configuration
  target_node    = var.target_node
  hostname       = var.hostname
  root_password  = var.root_password
  ssh_public_keys = var.ssh_public_keys

  # Resource allocation for testing/development
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

  # Homelab settings - can be powered off/on frequently
  onboot           = false  # Don't auto-start on boot
  start_on_create  = true
  unprivileged     = true
  enable_nesting   = true   # Enable for Docker experiments

  # Tags for organization
  tags = "homelab,dns,experimental"
}
"@ | Out-File -FilePath "environments\homelab\dns-server\main.tf" -Encoding UTF8

# Create environments/homelab/dns-server/terraform.tfvars
@"
# Homelab DNS Server Configuration
# Experimental/testing DNS service configuration

# Basic container settings
hostname = "dns-lab"
target_node = "proxmox-node-1"  # Replace with your actual Proxmox node name

# Network configuration - separate network segment for homelab
network_ip      = "192.168.86.20/24"  # Different IP for lab on same network
network_gateway = "192.168.86.1"      # Same gateway
network_bridge  = "vmbr0"             # Adjust if using separate lab bridge

# Resource allocation for experimental use
cores  = 1
memory = 512   # 512MB RAM - minimal for testing
swap   = 512   # 512MB swap
disk_size = "8G"

# Storage pool
storage = "local-lvm"  # Adjust based on your Proxmox storage

# SSH access - replace with your actual public key
ssh_public_keys = ""  # Add your SSH public key here

# Root password - use a secure password
root_password = "labpassword123"  # Change this!

# Proxmox connection details - use environment variables or .tfvars.local
# proxmox_api_url = "https://your-proxmox-host:8006/api2/json"
# proxmox_user = "root@pam"
# proxmox_password = "your-password"  # Better to use API tokens
# proxmox_tls_insecure = true
"@ | Out-File -FilePath "environments\homelab\dns-server\terraform.tfvars" -Encoding UTF8

# Create environments/homelab/dns-server/terragrunt.hcl
@"
# Terragrunt configuration for homelab DNS server
# Future Terragrunt migration configuration

# Include the root terragrunt.hcl configurations
include "root" {
  path = find_in_parent_folders()
}

# Include the environment-specific configurations
include "env" {
  path = find_in_parent_folders("env.hcl")
}

# Terraform source module
terraform {
  source = "../../../modules/proxmox-lxc"
}

# Input variables
inputs = {
  # Basic configuration
  hostname       = "dns-lab"
  target_node    = "proxmox-node-1"
  
  # Network configuration
  network_ip      = "192.168.86.20/24"
  network_gateway = "192.168.86.1"
  network_bridge  = "vmbr0"
  
  # Resource allocation
  cores     = 1
  memory    = 512
  swap      = 512
  disk_size = "8G"
  storage   = "local-lvm"
  
  # Homelab settings
  onboot           = false
  start_on_create  = true
  unprivileged     = true
  enable_nesting   = true
  
  tags = "homelab,dns,experimental"
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = var.proxmox_tls_insecure
}
EOF
}
"@ | Out-File -FilePath "environments\homelab\dns-server\terragrunt.hcl" -Encoding UTF8

# Create common.tfvars files
@"
# Common variables for home environment
# Shared configuration across all home infrastructure

# Proxmox connection details
# Note: Use environment variables or terraform.tfvars.local for sensitive values
# export TF_VAR_proxmox_api_url="https://your-proxmox-host:8006/api2/json"
# export TF_VAR_proxmox_user="root@pam"
# export TF_VAR_proxmox_password="your-password"

proxmox_tls_insecure = true  # Set to false if using valid certificates

# Default Proxmox settings for home environment
default_target_node = "proxmox-node-1"  # Replace with your node name
default_storage = "local-lvm"

# Home network configuration
home_network = {
  subnet  = "192.168.86.0/24"
  gateway = "192.168.86.1"
  domain  = "home.local"
  bridge  = "vmbr0"
}

# Default resource allocation for home services
default_resources = {
  cores     = 2
  memory    = 1024
  swap      = 1024
  disk_size = "10G"
}

# SSH configuration
# Replace with your actual SSH public key
default_ssh_keys = ""

# Default passwords (use Ansible vault or environment variables in production)
# These are placeholders - replace with secure values
default_root_password = "changeme123"

# Tags for organization
default_tags = "home,production"
"@ | Out-File -FilePath "environments\home\common.tfvars" -Encoding UTF8

@"
# Common variables for homelab environment
# Shared configuration across all homelab infrastructure

# Proxmox connection details
# Note: Use environment variables or terraform.tfvars.local for sensitive values
# export TF_VAR_proxmox_api_url="https://your-proxmox-host:8006/api2/json"
# export TF_VAR_proxmox_user="root@pam"
# export TF_VAR_proxmox_password="your-password"

proxmox_tls_insecure = true  # Set to false if using valid certificates

# Default Proxmox settings for homelab environment
default_target_node = "proxmox-node-1"  # Replace with your node name
default_storage = "local-lvm"

# Homelab network configuration
homelab_network = {
  subnet  = "192.168.86.0/24"
  gateway = "192.168.86.1"
  domain  = "lab.local"
  bridge  = "vmbr0"  # Same network, different IPs
}

# Default resource allocation for homelab services (minimal for testing)
default_resources = {
  cores     = 1
  memory    = 512
  swap      = 512
  disk_size = "8G"
}

# SSH configuration
# Replace with your actual SSH public key
default_ssh_keys = ""

# Default passwords (use Ansible vault or environment variables)
default_root_password = "labpassword123"

# Tags for organization
default_tags = "homelab,experimental"

# Experimental features enabled
experimental_features = {
  nesting_enabled = true   # For Docker-in-LXC experiments
  auto_start      = false  # Don't auto-start lab services
}
"@ | Out-File -FilePath "environments\homelab\common.tfvars" -Encoding UTF8

# Create ansible.cfg
@"
# Ansible Configuration for Homelab Infrastructure

[defaults]
# Inventory configuration
inventory = inventory/
host_key_checking = False
gathering = smart
fact_caching = memory
fact_caching_timeout = 3600

# Output and logging
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
log_path = ./ansible.log

# SSH configuration
remote_user = root
private_key_file = ~/.ssh/id_rsa
timeout = 30
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Performance tuning
forks = 10
pipelining = True
control_path_dir = /tmp/.ansible-cp

# Role and collection paths
roles_path = roles:~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
collections_paths = ~/.ansible/collections:/usr/share/ansible/collections

# Privilege escalation
become = True
become_method = sudo
become_ask_pass = False

[inventory]
# Enable inventory plugins
enable_plugins = host_list, script, auto, yaml, ini, toml

[ssh_connection]
# SSH connection optimizations
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
"@ | Out-File -FilePath "ansible\ansible.cfg" -Encoding UTF8

# Create requirements.yml
@"
# Ansible Requirements
# Collections and roles needed for homelab infrastructure management

---
collections:
  # Community general collection for various modules
  - name: community.general
    version: ">=7.0.0"
  
  # POSIX collection for system management
  - name: ansible.posix
    version: ">=1.5.0"
  
  # Docker collection if using containerized services
  - name: community.docker
    version: ">=3.4.0"

roles:
  # Pi-hole installation and configuration
  - name: r_pufky.pihole
    src: https://github.com/r-pufky/ansible-pihole
    version: main
  
  # Alternative Pi-hole role
  - name: geerlingguy.docker
    src: geerlingguy.docker
    version: ">=6.0.0"
  
  # System hardening and security
  - name: dev-sec.os-hardening
    src: dev-sec.os-hardening
    version: ">=7.0.0"
  
  # Firewall management
  - name: geerlingguy.firewall
    src: geerlingguy.firewall
    version: ">=2.0.0"
"@ | Out-File -FilePath "ansible\requirements.yml" -Encoding UTF8

# Create site.yml playbook
@"
# Main site playbook for homelab infrastructure
# Orchestrates all service deployments and configurations

---
- name: Deploy and configure all homelab services
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Display deployment information
      ansible.builtin.debug:
        msg: |
          Starting homelab infrastructure deployment
          Target environments: {{ ansible_limit | default('all') }}
          Timestamp: {{ ansible_date_time.iso8601 }}

# DNS Server deployment
- import_playbook: dns-server.yml
  when: "'dns_servers' in group_names or inventory_hostname in groups.get('dns_servers', [])"

# Future service playbooks can be added here
# - import_playbook: monitoring.yml
# - import_playbook: media-server.yml
# - import_playbook: reverse-proxy.yml

- name: Post-deployment tasks
  hosts: all
  gather_facts: true
  tasks:
    - name: Verify services are running
      ansible.builtin.service:
        name: "{{ item }}"
        state: started
      loop:
        - ssh
      ignore_errors: true
      
    - name: Display deployment summary
      ansible.builtin.debug:
        msg: |
          Deployment completed for {{ inventory_hostname }}
          IP Address: {{ ansible_default_ipv4.address | default('N/A') }}
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
          Uptime: {{ ansible_uptime_seconds | default(0) | int // 60 }} minutes
"@ | Out-File -FilePath "ansible\playbooks\site.yml" -Encoding UTF8

# Create dns-server.yml playbook
@"
# DNS Server deployment playbook
# Configures Pi-hole for DNS filtering and DHCP services

---
- name: Deploy and configure DNS server (Pi-hole)
  hosts: dns_servers
  become: true
  gather_facts: true
  
  vars:
    # Pi-hole configuration variables
    pihole_webpassword: "{{ vault_pihole_password | default('changeme123') }}"
    pihole_dns_servers:
      - "1.1.1.1"
      - "1.0.0.1"
      - "8.8.8.8"
      - "8.8.4.4"
    
    # DHCP configuration (adjust for your network)
    pihole_dhcp_enabled: true
    pihole_dhcp_start: "{{ dhcp_range_start | default('192.168.86.100') }}"
    pihole_dhcp_end: "{{ dhcp_range_end | default('192.168.86.200') }}"
    pihole_dhcp_router: "{{ ansible_default_ipv4.gateway | default('192.168.86.1') }}"
    
    # Block lists
    pihole_blocklists:
      - "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
      - "https://mirror1.malwaredomains.com/files/justdomains"
      - "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
      - "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"

  pre_tasks:
    - name: Update package cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"

    - name: Install required packages
      ansible.builtin.apt:
        name:
          - curl
          - wget
          - ca-certificates
          - gnupg
        state: present
      when: ansible_os_family == "Debian"

  tasks:
    - name: Create pi-hole configuration directory
      ansible.builtin.file:
        path: /etc/pihole
        state: directory
        mode: '0755'

    - name: Download and install Pi-hole
      ansible.builtin.shell: |
        curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended
      args:
        creates: /usr/local/bin/pihole
      environment:
        PIHOLE_SKIP_OS_CHECK: true

    - name: Configure Pi-hole web password
      ansible.builtin.shell: |
        pihole -a -p "{{ pihole_webpassword }}"
      no_log: true
      when: pihole_webpassword is defined

    - name: Configure DNS servers
      ansible.builtin.lineinfile:
        path: /etc/pihole/setupVars.conf
        regexp: '^PIHOLE_DNS_'
        line: "PIHOLE_DNS_{{ item.0 + 1 }}={{ item.1 }}"
      loop: "{{ pihole_dns_servers | indexed }}"
      notify: restart pihole-FTL

    - name: Enable DHCP if configured
      ansible.builtin.lineinfile:
        path: /etc/pihole/setupVars.conf
        regexp: '^DHCP_ACTIVE='
        line: "DHCP_ACTIVE={{ 'true' if pihole_dhcp_enabled else 'false' }}"
      when: pihole_dhcp_enabled is defined
      notify: restart pihole-FTL

    - name: Configure DHCP range
      ansible.builtin.blockinfile:
        path: /etc/pihole/setupVars.conf
        marker: "# {mark} ANSIBLE MANAGED DHCP CONFIG"
        block: |
          DHCP_START={{ pihole_dhcp_start }}
          DHCP_END={{ pihole_dhcp_end }}
          DHCP_ROUTER={{ pihole_dhcp_router }}
          DHCP_LEASETIME=24
          PIHOLE_DOMAIN=local
        backup: true
      when: pihole_dhcp_enabled | default(false)
      notify: restart pihole-FTL

    - name: Add custom blocklists
      ansible.builtin.lineinfile:
        path: /etc/pihole/adlists.list
        line: "{{ item }}"
        create: true
      loop: "{{ pihole_blocklists | default([]) }}"
      notify: update pihole blocklists

    - name: Ensure pihole-FTL service is running
      ansible.builtin.systemd:
        name: pihole-FTL
        state: started
        enabled: true

    - name: Configure firewall for Pi-hole services
      ansible.builtin.ufw:
        rule: allow
        port: "{{ item }}"
        proto: "{{ 'tcp' if item in ['80', '443', '4711'] else 'udp' }}"
      loop:
        - "53"    # DNS
        - "67"    # DHCP
        - "80"    # Web interface
        - "4711"  # FTL API
      when: ansible_os_family == "Debian"

  handlers:
    - name: restart pihole-FTL
      ansible.builtin.systemd:
        name: pihole-FTL
        state: restarted

    - name: update pihole blocklists
      ansible.builtin.shell: pihole -g
      async: 300
      poll: 0

  post_tasks:
    - name: Display Pi-hole information
      ansible.builtin.debug:
        msg: |
          Pi-hole installation completed!
          Web interface: http://{{ ansible_default_ipv4.address }}/admin
          DNS server: {{ ansible_default_ipv4.address }}
          DHCP enabled: {{ pihole_dhcp_enabled | default(false) }}
          {% if pihole_dhcp_enabled | default(false) %}
          DHCP range: {{ pihole_dhcp_start }} - {{ pihole_dhcp_end }}
          {% endif %}
"@ | Out-File -FilePath "ansible\playbooks\dns-server.yml" -Encoding UTF8

# Create inventory files
@"
# Home environment inventory
# Production DNS/DHCP services for main home network

---
all:
  children:
    dns_servers:
      hosts:
        dns-home:
          ansible_host: 192.168.86.10
          ansible_user: root
          environment: home
          service_level: production
          
  vars:
    # Environment-specific variables
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    
    # Network configuration for home environment
    network_domain: home.local
    network_gateway: 192.168.86.1
    network_subnet: "192.168.86.0/24"
    
    # DHCP configuration for home network
    dhcp_range_start: "192.168.86.100"
    dhcp_range_end: "192.168.86.200"
    dhcp_lease_time: 24  # hours
    
    # DNS configuration
    upstream_dns_servers:
      - "1.1.1.1"      # Cloudflare
      - "1.0.0.1"      # Cloudflare
      - "8.8.8.8"      # Google
      - "8.8.4.4"      # Google
"@ | Out-File -FilePath "ansible\inventory\home\hosts.yml" -Encoding UTF8

@"
# Homelab environment inventory
# Experimental/testing DNS services for lab network

---
all:
  children:
    dns_servers:
      hosts:
        dns-lab:
          ansible_host: 192.168.86.20
          ansible_user: root
          environment: homelab
          service_level: experimental
          
  vars:
    # Environment-specific variables
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    
    # Network configuration for homelab environment
    network_domain: lab.local
    network_gateway: 192.168.86.1
    network_subnet: "192.168.86.0/24"
    
    # DHCP configuration for lab network
    dhcp_range_start: "192.168.86.50"
    dhcp_range_end: "192.168.86.99"
    dhcp_lease_time: 12  # hours (shorter for testing)
    
    # DNS configuration
    upstream_dns_servers:
      - "1.1.1.1"      # Cloudflare
      - "9.9.9.9"      # Quad9 (for testing different providers)
      - "8.8.8.8"      # Google
"@ | Out-File -FilePath "ansible\inventory\homelab\hosts.yml" -Encoding UTF8

# Create group_vars files
@"
# Group variables for home environment
# Production configuration for home network services

---
# Environment identification
environment: home
service_level: production

# System configuration
timezone: "America/New_York"  # Adjust for your timezone
ntp_servers:
  - pool.ntp.org
  - time.nist.gov

# Security settings
enable_fail2ban: true
enable_ufw: true
ssh_port: 22
ssh_password_auth: false
ssh_root_login: true  # Using keys only

# Pi-hole specific configuration for home
pihole_config:
  interface: eth0
  ipv4_address: "192.168.86.10/24"
  ipv6_address: ""  # Disable IPv6 if not used
  query_logging: true
  install_web_server: true
  install_web_interface: true
  lighttpd_enabled: true
  cache_size: 10000
  
  # Privacy settings
  privacy_level: 0  # Show everything
  
  # Blocking configuration
  blocking_enabled: true
  default_block_page: true
  
  # DHCP settings for home network
  dhcp:
    enabled: true
    start: "{{ dhcp_range_start }}"
    end: "{{ dhcp_range_end }}"
    router: "{{ network_gateway }}"
    lease_time: "{{ dhcp_lease_time }}h"
    domain: "{{ network_domain }}"

# Custom DNS records for home devices
custom_dns_records:
  - name: router
    ip: "{{ network_gateway }}"
  - name: nas
    ip: "192.168.86.30"
  - name: printer
    ip: "192.168.86.40"

# Block lists for home use (family-friendly + security)
pihole_blocklists:
  # Primary lists
  - "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
  - "https://mirror1.malwaredomains.com/files/justdomains"
  
  # Tracking and ads
  - "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
  - "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
  
  # Additional security
  - "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
  - "https://someonewhocares.org/hosts/zero/hosts"

# Monitoring and logging
log_queries: true
log_retention_days: 30
enable_metrics: true
"@ | Out-File -FilePath "ansible\inventory\home\group_vars\all.yml" -Encoding UTF8

@"
# Group variables for homelab environment
# Experimental configuration for testing and learning

---
# Environment identification
environment: homelab
service_level: experimental

# System configuration
timezone: "America/New_York"  # Adjust for your timezone
ntp_servers:
  - pool.ntp.org

# Security settings (relaxed for testing)
enable_fail2ban: false  # Disabled for easier testing
enable_ufw: true
ssh_port: 22
ssh_password_auth: false
ssh_root_login: true

# Pi-hole specific configuration for homelab
pihole_config:
  interface: eth0
  ipv4_address: "192.168.86.20/24"
  ipv6_address: ""
  query_logging: true
  install_web_server: true
  install_web_interface: true
  lighttpd_enabled: true
  cache_size: 5000  # Smaller cache for testing
  
  # Privacy settings (more verbose for testing)
  privacy_level: 0
  
  # Blocking configuration
  blocking_enabled: true
  default_block_page: true
  
  # DHCP settings for lab network
  dhcp:
    enabled: true
    start: "{{ dhcp_range_start }}"
    end: "{{ dhcp_range_end }}"
    router: "{{ network_gateway }}"
    lease_time: "{{ dhcp_lease_time }}h"
    domain: "{{ network_domain }}"

# Custom DNS records for lab devices
custom_dns_records:
  - name: gateway
    ip: "{{ network_gateway }}"
  - name: test-server
    ip: "192.168.86.25"
  - name: dev-box
    ip: "192.168.86.26"

# Block lists for testing (smaller set for faster updates)
pihole_blocklists:
  # Basic lists for testing
  - "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
  - "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
  
  # Test with different formats
  - "https://mirror1.malwaredomains.com/files/justdomains"

# Monitoring and logging (verbose for debugging)
log_queries: true
log_retention_days: 7  # Shorter retention for testing
enable_metrics: true
debug_mode: true  # Enable additional debugging
"@ | Out-File -FilePath "ansible\inventory\homelab\group_vars\all.yml" -Encoding UTF8

# Create .gitkeep for roles directory
@"
# This file ensures the roles directory is tracked by git
# Custom Ansible roles will be placed in this directory
# Galaxy roles will be installed here via ansible-galaxy install -r requirements.yml
"@ | Out-File -FilePath "ansible\roles\.gitkeep" -Encoding UTF8

Write-Host ""
Write-Host "All Ansible configuration files created successfully!" -ForegroundColor Green
Write-Host "Network configuration updated to use 192.168.86.0/24" -ForegroundColor Cyan
Write-Host ""
Write-Host "IP Address assignments:" -ForegroundColor Yellow
Write-Host "  Home DNS Server: 192.168.86.10" -ForegroundColor White
Write-Host "  Homelab DNS Server: 192.168.86.20" -ForegroundColor White
Write-Host "  Home DHCP Range: 192.168.86.100-200" -ForegroundColor White
Write-Host "  Homelab DHCP Range: 192.168.86.50-99" -ForegroundColor White