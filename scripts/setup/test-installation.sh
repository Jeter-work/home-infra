#!/bin/bash
# Test DevSecOps platform tools installation

set -euo pipefail

echo "=== Testing DevSecOps Platform Installation ==="

# Function to test command
test_command() {
    local cmd="$1"
    local description="$2"
    
    if command -v "$cmd" &> /dev/null; then
        echo "✅ $description: $($cmd --version 2>&1 | head -1)"
    else
        echo "❌ $description: NOT FOUND"
        return 1
    fi
}

# Test core tools
echo ""
echo "Core Platform Tools:"
test_command "git" "Git"
test_command "ansible" "Ansible"
test_command "python3" "Python3"

echo ""
echo "Infrastructure Tools:"
test_command "tofu" "OpenTofu"
test_command "kubectl" "Kubernetes CLI"
test_command "helm" "Helm"
test_command "k3sup" "K3s Installer"
test_command "flux" "FluxCD"

echo ""
echo "Container Tools:"
test_command "podman" "Podman"
test_command "docker" "Docker"
test_command "buildah" "Buildah"
test_command "skopeo" "Skopeo"

echo ""
echo "Security Tools:"
test_command "trivy" "Trivy Scanner"

echo ""
echo "CI/CD Tools:"
test_command "gitlab-runner" "GitLab Runner"

echo ""
echo "Network Tools:"
test_command "dig" "DNS Lookup"
test_command "curl" "HTTP Client"
test_command "jq" "JSON Processor"

echo ""
echo "=== Service Status ==="
echo "Docker service: $(systemctl is-active docker 2>/dev/null || echo 'inactive')"

echo ""
echo "=== User Groups ==="
echo "Current user groups: $(groups)"

echo ""
echo "=== Test Complete ==="
if docker ps &>/dev/null; then
    echo "✅ Docker access working"
else
    echo "⚠️  Docker access requires logout/login or run: newgrp docker"
fi