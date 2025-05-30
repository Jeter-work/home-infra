# Updated README.md and Fedora Setup Guide

## Fixed README.md for home-infra repository

```markdown
# Homelab Infrastructure Project

This project contains OpenTofu/Terragrunt infrastructure-as-code and Ansible configuration management for home and homelab services.

## Project Structure

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

## Getting Started

1. Initialize OpenTofu in each environment directory
2. Configure Proxmox provider credentials
3. Run `tofu plan` and `tofu apply` to provision infrastructure
4. Use Ansible to configure and manage services

## Environment Descriptions

- **home/**: Production-like services for daily use (DNS/DHCP for main network)
- **homelab/**: Experimental and learning environment (can be torn down safely)

## Prerequisites

### Required Tools
- OpenTofu >= 1.6.0
- Ansible >= 8.0
- Python >= 3.9
- Git

### Development Environment Setup
See [Fedora Setup Guide](#fedora-workstation-setup) for complete development environment configuration.

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/home-infra.git
cd home-infra
```

### 2. Setup Development Environment
```bash
# Install required tools (see Fedora setup guide below)
./scripts/setup/fedora-dev-setup.sh

# Install Ansible dependencies
cd ansible
ansible-galaxy install -r requirements.yml
```

### 3. Configure Environment
```bash
# Copy and edit environment variables
cp .env.example .env
vi .env

# Source environment
source .env
```

### 4. Deploy Infrastructure
```bash
# Initialize and deploy Pi-hole DNS server
cd environments/home/dns-server
tofu init
tofu plan
tofu apply

# Configure with Ansible
cd ../../../ansible
ansible-playbook -i inventory/home/hosts.yml playbooks/dns-server.yml
```

## Fedora Workstation Setup

### Prerequisites Installation Script

Create `scripts/setup/fedora-dev-setup.sh`:

```bash
#!/bin/bash
# Fedora 42 Development Environment Setup for DevSecOps Homelab

set -euo pipefail

echo "Setting up Fedora 42 DevSecOps workstation..."

# Update system
sudo dnf update -y

# Install development tools and dependencies
# Note: Fedora 42 uses dnf5 with "development-tools" group name
sudo dnf group install -y development-tools
sudo dnf install -y --skip-unavailable \
    gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    patch \
    pkgconfig \
    git \
    curl \
    wget \
    vim \
    tmux \
    tree \
    jq \
    yq \
    unzip \
    python3 \
    python3-pip \
    golang \
    nodejs \
    npm

# Install OpenTofu
echo "Installing OpenTofu..."
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
sudo ./install-opentofu.sh --install-method rpm
rm install-opentofu.sh

# Verify OpenTofu installation
tofu version

# Install Ansible via pip (latest version)
echo "Installing Ansible..."
python3 -m pip install --user ansible ansible-lint

# Add pip user bin to PATH if not already there
if ! echo $PATH | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi

# Install additional DevSecOps tools
echo "Installing additional DevSecOps tools..."

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# k3sup
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/

# Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Trivy security scanner
sudo dnf install -y https://github.com/aquasecurity/trivy/releases/download/v0.48.3/trivy_0.48.3_Linux-64bit.rpm

# Docker (optional, for local development)
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# VS Code (optional)
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

# Create workspace directories
mkdir -p ~/workspace/{homelab,projects,tools}
mkdir -p ~/.config/ansible

echo "Creating Ansible configuration..."
cat > ~/.config/ansible/ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = ./inventory
roles_path = ./roles
collections_paths = ~/.ansible/collections
timeout = 30
gathering = smart
fact_caching = memory
stdout_callback = yaml
callbacks_enabled = profile_tasks

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
pipelining = True
EOF

echo "Setting up Git configuration prompts..."
echo "Please configure Git with your details:"
read -p "Git username: " git_username
read -p "Git email: " git_email
git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global pull.rebase false

echo "Generating SSH key for Git/Ansible operations..."
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N ""
    echo "SSH public key:"
    cat ~/.ssh/id_ed25519.pub
    echo "Add this key to your GitHub account and Proxmox/target systems"
fi

echo ""
echo "=== Setup Complete ==="
echo "Tools installed:"
echo "- OpenTofu: $(tofu version | head -1)"
echo "- Ansible: $(ansible --version | head -1)"
echo "- kubectl: $(kubectl version --client --short 2>/dev/null)"
echo "- Helm: $(helm version --short)"
echo "- Docker: $(docker --version)"
echo ""
echo "Next steps:"
echo "1. Log out and back in to apply group changes"
echo "2. Add SSH key to GitHub: cat ~/.ssh/id_ed25519.pub"
echo "3. Clone your repositories to ~/workspace/"
echo "4. Configure environment variables in your projects"
echo ""
echo "Development workspace: ~/workspace/"
echo "Ansible config: ~/.config/ansible/ansible.cfg"
```

### Environment Configuration

Create `.env.example` in project root:

```bash
# Proxmox Configuration
export TF_VAR_proxmox_api_url="https://your-proxmox-ip:8006/api2/json"
export TF_VAR_proxmox_user="root@pam"
export TF_VAR_proxmox_password="your-proxmox-password"
export TF_VAR_proxmox_tls_insecure="true"

# Ansible Configuration
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_CONFIG="~/.config/ansible/ansible.cfg"

# SSH Configuration
export ANSIBLE_PRIVATE_KEY_FILE="~/.ssh/id_ed25519"

# Project Configuration
export HOMELAB_DOMAIN="home.lab"
export HOMELAB_NETWORK_PREFIX="192.168.86"
```

### Updated Ansible Configuration for Fedora

Update `ansible/ansible.cfg`:

```ini
[defaults]
host_key_checking = False
inventory = ./inventory
roles_path = ./roles
collections_paths = ~/.ansible/collections:/usr/share/ansible/collections
timeout = 30
gathering = smart
fact_caching = memory
stdout_callback = yaml
callbacks_enabled = profile_tasks
remote_user = devops
private_key_file = ~/.ssh/id_ed25519

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
pipelining = True
control_path = /tmp/ansible-%%h-%%p-%%r

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

### Updated requirements.yml for Ansible

```yaml
---
collections:
  - name: community.general
    version: ">=7.0.0"
  - name: ansible.posix
    version: ">=1.5.0"
  - name: community.crypto
    version: ">=2.0.0"
  - name: containers.podman
    version: ">=1.0.0"

roles:
  - name: geerlingguy.security
    version: "2.0.1"
  - name: geerlingguy.firewall
    version: "3.1.1"
```

### Enhanced Pi-hole Playbook for Ubuntu LXC

Update `ansible/playbooks/dns-server.yml`:

```yaml
---
- name: Deploy Pi-hole DNS Server
  hosts: piholes
  gather_facts: true
  become: true
  vars_files:
    - ../roles/pi-hole/vars/main.yml

  pre_tasks:
    - name: Generate random password for Pi-hole web interface
      set_fact:
        pihole_password: "{{ lookup('password', '/dev/null length=32 chars=ascii_letters,digits') }}"
      when: pihole_password is not defined
      run_once: true
      delegate_to: localhost

    - name: Display target system information
      debug:
        msg: 
          - "Target: {{ inventory_hostname }}"
          - "IP: {{ ansible_default_ipv4.address }}"
          - "OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"
          - "Architecture: {{ ansible_architecture }}"

  roles:
    - role: pi-hole
    - role: common

  post_tasks:
    - name: Display Pi-hole access information
      debug:
        msg:
          - "Pi-hole web interface: http://{{ ansible_default_ipv4.address }}/admin"
          - "DNS server: {{ ansible_default_ipv4.address }}"
          - "Admin password: {{ pihole_password }}"
      run_once: true

    - name: Save admin password to local file
      copy:
        content: |
          Pi-hole Admin Password: {{ pihole_password }}
          Web Interface: http://{{ ansible_default_ipv4.address }}/admin
          DNS Server: {{ ansible_default_ipv4.address }}
          Generated: {{ ansible_date_time.iso8601 }}
        dest: "{{ playbook_dir }}/../pihole_credentials.txt"
        mode: '0600'
      delegate_to: localhost
      run_once: true
```

### Quick Start Commands for Fedora

```bash
# 1. Setup development environment
chmod +x scripts/setup/fedora-dev-setup.sh
./scripts/setup/fedora-dev-setup.sh

# 2. Clone and setup project
git clone https://github.com/yourusername/home-infra.git ~/workspace/home-infra
cd ~/workspace/home-infra

# 3. Configure environment
cp .env.example .env
vi .env  # Edit with your Proxmox details
source .env

# 4. Install Ansible dependencies
cd ansible
ansible-galaxy install -r requirements.yml

# 5. Test connectivity to Proxmox/target systems
ansible -i inventory/home/hosts.yml all -m ping

# 6. Deploy Pi-hole infrastructure
cd ../environments/home/dns-server
tofu init
tofu plan
tofu apply

# 7. Configure Pi-hole with Ansible
cd ../../../ansible
ansible-playbook -i inventory/home/hosts.yml playbooks/dns-server.yml

# 8. Access Pi-hole web interface
firefox http://192.168.86.2/admin
```

### Fedora-Specific Optimizations

#### Firewall Configuration for Development
```bash
# Allow common development ports
sudo firewall-cmd --permanent --add-port=8080/tcp  # Common dev port
sudo firewall-cmd --permanent --add-port=3000/tcp  # Node.js dev
sudo firewall-cmd --permanent --add-port=8000/tcp  # Python dev
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

#### SELinux Considerations
```bash
# Set appropriate SELinux contexts for development
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P container_manage_cgroup 1
```

### IDE Configuration for VS Code

Create `.vscode/settings.json`:

```json
{
    "ansible.python.interpreterPath": "/usr/bin/python3",
    "ansible.validation.enabled": true,
    "ansible.validation.lint.enabled": true,
    "files.associations": {
        "*.yml": "ansible",
        "*.yaml": "ansible"
    },
    "terraform.languageServer": {
        "external": true,
        "pathToBinary": "/usr/local/bin/terraform-ls"
    }
}
```

This setup provides you with a complete Fedora 42 development environment optimized for DevSecOps work with all the tools you need for your homelab infrastructure automation.