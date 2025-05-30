# Homelab Infrastructure Setup Instructions

Complete step-by-step guide to deploy your DNS/DHCP infrastructure using OpenTofu and Ansible.

## Prerequisites

Before starting, ensure you have:

1. **Proxmox VE server** running and accessible
2. **OpenTofu** installed on your local machine
3. **Ansible** installed on your local machine
4. **SSH key pair** generated
5. **Git** for version control

### Install Required Tools

```powershell
# Install OpenTofu (Windows)
winget install OpenTofu.OpenTofu

# Install Ansible (Windows with WSL2 or use Linux subsystem)
# Or use Docker: docker run --rm -it quay.io/ansible/ansible:latest

# Install Git if not already installed
winget install Git.Git
```

## Step 1: Initialize Project Structure

1. **Navigate to your project directory:**
   ```powershell
   cd C:\Users\scott\code\home-infra
   ```

2. **Run the first setup script:**
   ```powershell
   # You may need to allow script execution
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   
   # Run the script
   .\setup-project.ps1
   ```

3. **Run the second setup script:**
   ```powershell
   .\setup-ansible.ps1
   ```

## Step 2: Configure Your Environment

### A. SSH Keys
1. **Generate SSH key if you don't have one:**
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```

2. **Copy your public key content:**
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```

3. **Add your SSH public key to both terraform.tfvars files:**
   - `environments/home/dns-server/terraform.tfvars`
   - `environments/homelab/dns-server/terraform.tfvars`
   
   Replace this line:
   ```hcl
   ssh_public_keys = ""  # Add your SSH public key here
   ```
   
   With your actual key:
   ```hcl
   ssh_public_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAC... your-email@example.com"
   ```

### B. Network Configuration
The scripts are pre-configured for **192.168.86.0/24** network:
- **Home DNS Server:** 192.168.86.10
- **Homelab DNS Server:** 192.168.86.20
- **Home DHCP Range:** 192.168.86.100-200
- **Homelab DHCP Range:** 192.168.86.50-99

**If your network is different**, update these files:
- `environments/home/dns-server/terraform.tfvars`
- `environments/homelab/dns-server/terraform.tfvars`
- `ansible/inventory/home/hosts.yml`
- `ansible/inventory/homelab/hosts.yml`

### C. Proxmox Configuration

1. **Update Proxmox node name** in terraform.tfvars files:
   ```hcl
   target_node = "your-actual-node-name"  # Replace with your Proxmox node
   ```

2. **Set up Proxmox credentials** (choose one method):

   **Method 1: Environment Variables (Recommended)**
   ```powershell
   $env:TF_VAR_proxmox_api_url = "https://your-proxmox-ip:8006/api2/json"
   $env:TF_VAR_proxmox_user = "root@pam"
   $env:TF_VAR_proxmox_password = "your-password"
   ```

   **Method 2: Create terraform.tfvars.local file**
   ```hcl
   # environments/home/dns-server/terraform.tfvars.local
   proxmox_api_url = "https://192.168.86.5:8006/api2/json"
   proxmox_user = "root@pam"
   proxmox_password = "your-secure-password"
   proxmox_tls_insecure = true
   ```

### D. Update Passwords
Change default passwords in terraform.tfvars files:
```hcl
root_password = "your-secure-password"  # Change from default
```

## Step 3: Initialize and Deploy Infrastructure

### A. Initialize OpenTofu

1. **Initialize home environment:**
   ```powershell
   cd environments\home\dns-server
   tofu init
   ```

2. **Plan the deployment:**
   ```powershell
   tofu plan
   ```

3. **Apply the configuration:**
   ```powershell
   tofu apply
   ```

4. **Repeat for homelab environment:**
   ```powershell
   cd ..\..\homelab\dns-server
   tofu init
   tofu plan
   tofu apply
   ```

### B. Verify Container Creation
Check Proxmox web interface to confirm containers are created and running.

## Step 4: Configure Services with Ansible

### A. Install Ansible Requirements
```powershell
cd ..\..\..
cd ansible
ansible-galaxy install -r requirements.yml
```

### B. Test Connectivity
```powershell
# Test home environment
ansible -i inventory/home/ dns_servers -m ping

# Test homelab environment  
ansible -i inventory/homelab/ dns_servers -m ping
```

### C. Deploy Pi-hole

1. **Deploy to home environment:**
   ```powershell
   ansible-playbook -i inventory/home/ playbooks/dns-server.yml
   ```

2. **Deploy to homelab environment:**
   ```powershell
   ansible-playbook -i inventory/homelab/ playbooks/dns-server.yml
   ```

## Step 5: Access and Configure Pi-hole

### Access Web Interfaces
- **Home Pi-hole:** http://192.168.86.10/admin
- **Homelab Pi-hole:** http://192.168.86.20/admin

### Default Login
- **Username:** admin
- **Password:** changeme123 (change this!)

### Post-Deployment Tasks

1. **Change Pi-hole admin password:**
   ```bash
   ssh root@192.168.86.10
   pihole -a -p newpassword
   ```

2. **Configure your router/devices** to use new DNS server:
   - Primary DNS: 192.168.86.10 (home) or 192.168.86.20 (homelab)
   - Secondary DNS: 8.8.8.8 (fallback)

3. **Enable DHCP** (optional):
   - Disable DHCP on your router
   - Pi-hole will handle DHCP assignments

## Step 6: Version Control

1. **Initialize Git repository:**
   ```powershell
   git init
   git add .
   git commit -m "Initial homelab infrastructure setup"
   ```

2. **Add GitLab remote:**
   ```powershell
   git remote add origin https://gitlab.com/your-username/home-infra.git
   git push -u origin main
   ```

## Troubleshooting

### Common Issues

1. **SSH Connection Refused:**
   - Container may still be starting
   - Check Proxmox console for container status
   - Verify SSH key is correctly added

2. **Proxmox Authentication Errors:**
   - Verify API URL is correct
   - Check credentials
   - Ensure Proxmox user has sufficient permissions

3. **Network Issues:**
   - Verify IP addresses don't conflict with existing devices
   - Check if your network uses different subnet
   - Ensure Proxmox bridge configuration is correct

4. **Pi-hole Installation Fails:**
   - Check container has internet access
   - Verify DNS resolution in container
   - Check logs: `journalctl -u pihole-FTL`

### Useful Commands

```powershell
# Check OpenTofu state
tofu show

# Destroy resources if needed
tofu destroy

# Run specific Ansible tasks
ansible-playbook -i inventory/home/ playbooks/dns-server.yml --tags "pihole-config"

# Check Ansible inventory
ansible-inventory -i inventory/home/ --list
```

## Next Steps

1. **Monitor and maintain** your DNS/DHCP services
2. **Add monitoring** with Prometheus/Grafana
3. **Implement backup strategy** for Pi-hole configurations
4. **Consider migrating to Terragrunt** when ready for more complex infrastructure
5. **Add additional services** to your homelab using the same patterns

## Security Considerations

1. **Change all default passwords**
2. **Use SSH keys only** (disable password authentication)
3. **Regular updates** of containers and Pi-hole
4. **Firewall rules** to restrict access where needed
5. **Consider using Ansible Vault** for sensitive variables