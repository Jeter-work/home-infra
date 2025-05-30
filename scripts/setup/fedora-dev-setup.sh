#!/bin/bash
# Fedora 42 Development Environment Setup for DevSecOps Homelab

set -euo pipefail

echo "Setting up Fedora 42 DevSecOps workstation..."

# Update system
sudo dnf update -y

# Install development tools and dependencies
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
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
    python3-venv \
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