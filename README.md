# Homelab Infrastructure Project

This project contains OpenTofu/Terragrunt infrastructure-as-code and Ansible configuration management for homelab services.

## Project Structure

```
home-infra/
â”œâ”€â”€ .gitignore
â”œâ”€â”€ README.md
â”œâ”€â”€ modules/
â”‚   â””â”€â”€ proxmox-lxc/
â”‚       â”œâ”€â”€ main.tf
â”‚       â”œâ”€â”€ variables.tf
â”‚       â”œâ”€â”€ outputs.tf
â”‚       â””â”€â”€ versions.tf
â”œâ”€â”€ environments/
â”‚   â”œâ”€â”€ home/
â”‚   â”‚   â”œâ”€â”€ dns-server/
â”‚   â”‚   â”‚   â”œâ”€â”€ terragrunt.hcl
â”‚   â”‚   â”‚   â”œâ”€â”€ main.tf
â”‚   â”‚   â”‚   â””â”€â”€ terraform.tfvars
â”‚   â”‚   â””â”€â”€ common.tfvars
â”‚   â””â”€â”€ homelab/
â”‚       â”œâ”€â”€ dns-server/
â”‚       â”‚   â”œâ”€â”€ terragrunt.hcl
â”‚       â”‚   â”œâ”€â”€ main.tf
â”‚       â”‚   â””â”€â”€ terraform.tfvars
â”‚       â””â”€â”€ common.tfvars
â””â”€â”€ ansible/
    â”œâ”€â”€ ansible.cfg
    â”œâ”€â”€ requirements.yml
    â”œâ”€â”€ playbooks/
    â”‚   â”œâ”€â”€ site.yml
    â”‚   â””â”€â”€ dns-server.yml
    â”œâ”€â”€ roles/
    â”‚   â””â”€â”€ .gitkeep
    â””â”€â”€ inventory/
        â”œâ”€â”€ home/
        â”‚   â”œâ”€â”€ hosts.yml
        â”‚   â””â”€â”€ group_vars/
        â”‚       â””â”€â”€ all.yml
        â””â”€â”€ homelab/
            â”œâ”€â”€ hosts.yml
            â””â”€â”€ group_vars/
                â””â”€â”€ all.yml
```

## Getting Started

1. Initialize OpenTofu in each environment directory
2. Configure Proxmox provider credentials
3. Run `tofu plan` and `tofu apply` to provision infrastructure
4. Use Ansible to configure and manage services

## Environment Descriptions

- **home/**: Production-like services for daily use (DNS/DHCP for main network)
- **homelab/**: Experimental and learning environment (can be torn down safely)
