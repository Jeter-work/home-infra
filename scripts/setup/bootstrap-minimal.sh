#!/bin/bash
# Minimal Fedora Bootstrap for DevSecOps Platform Engineering
# Safe system package installation only

set -euo pipefail

echo "=== Fedora DevSecOps Platform Bootstrap ==="
echo "Installing minimal system packages for platform engineering..."

# Update system
echo "Updating system packages..."
sudo dnf update -y

# Install essential system packages only
echo "Installing essential packages..."
sudo dnf install -y \
    git \
    python3 \
    python3-pip \
    ansible \
    curl \
    wget \
    vim \
    tree \
    jq \
    yq \
    unzip

# Verify installations
echo ""
echo "=== Verification ==="
echo "Git version: $(git --version)"
echo "Python version: $(python3 --version)"
echo "Ansible version: $(ansible --version | head -1)"
echo "Curl version: $(curl --version | head -1)"

echo ""
echo "=== Bootstrap Complete ==="
echo "Next steps:"
echo "1. Run: ./scripts/clone-repos.sh"
echo "2. Run: ansible-playbook ansible/playbooks/fedora-workstation.yml"
echo ""
echo "Bootstrap completed successfully!"