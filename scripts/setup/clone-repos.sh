#!/bin/bash
# Clone DevSecOps repositories for platform engineering

set -euo pipefail

echo "=== Cloning DevSecOps Repositories ==="

# Create workspace directory
mkdir -p ~/workspace
cd ~/workspace

# Check if repos already exist
if [ -d "home-infra" ]; then
    echo "home-infra already exists, pulling latest..."
    cd home-infra && git pull && cd ..
else
    echo "Cloning home-infra repository..."
    git clone git@github.com:Jeter-work/home-infra.git
fi

if [ -d "portfolio" ]; then
    echo "portfolio already exists, pulling latest..."
    cd portfolio && git pull && cd ..
else
    echo "Cloning portfolio repository..."
    git clone git@github.com:Jeter-work/portfolio.git
fi

echo ""
echo "=== Repository Setup ==="
cd home-infra

# Set up Ansible requirements
cd ansible
ansible-galaxy install -r requirements.yml || echo "No requirements.yml found, skipping..."
cd ..

# Set up environment file
if [ ! -f .env ]; then
    echo "Creating environment configuration..."
    cp .env.example .env 2>/dev/null || cat > .env << 'EOF'
# Proxmox Configuration
export TF_VAR_proxmox_api_url="https://192.168.86.19:8006/api2/json"
export TF_VAR_proxmox_user="scott"
export TF_VAR_proxmox_password="Home@s4n4d4r!"
export TF_VAR_proxmox_tls_insecure="true"

# Ansible Configuration
export ANSIBLE_HOST_KEY_CHECKING=False

# Project Configuration
export HOMELAB_DOMAIN="homelab.lan"
export HOMELAB_NETWORK_PREFIX="192.168.86"
EOF
    echo "Please edit .env with your actual configuration"
fi

echo ""
echo "=== Repositories Cloned Successfully ==="
echo "Workspace location: ~/workspace/"
echo "- home-infra: ~/workspace/home-infra"
echo "- portfolio: ~/workspace/portfolio"
echo ""
echo "Next step: Run the workstation setup playbook"
echo "cd ~/workspace/home-infra && ansible-playbook ansible/playbooks/fedora-workstation.yml"