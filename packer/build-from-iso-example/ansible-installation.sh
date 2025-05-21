#!/bin/bash

# Script to install Ansible on Debian and Ubuntu
# Must be run with root or sudo privileges

set -e  # Exit on error

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No color

# Function to check root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root or with sudo${NC}"
        exit 1
    fi
}

# Function to check distribution
check_distro() {
    if ! grep -Ei 'debian|ubuntu' /etc/*release > /dev/null; then
        echo -e "${RED}Error: This script only supports Debian or Ubuntu${NC}"
        exit 1
    fi
}

# Function to install prerequisites
install_prerequisites() {
    echo "Updating repositories and installing prerequisites..."
    apt update -y
    apt install -y software-properties-common python3 python3-pip
}

# Function to add Ansible repository and install
install_ansible() {
    echo "Adding Ansible repository and installing..."
    if [[ -f /etc/os-release && $(grep -Ei 'ubuntu' /etc/os-release) ]]; then
        apt-add-repository -y ppa:ansible/ansible
        apt update -y
        apt install -y ansible
    else
        # For Debian, install Ansible directly from the default repositories
        echo "Installing Ansible via apt for Debian..."
        apt update -y
        apt install -y ansible
    fi
}

# Function to validate installation
validate_installation() {
    echo "Verifying Ansible installation..."
    if command -v ansible >/dev/null 2>&1; then
        ansible_version=$(ansible --version | head -n 1)
        echo -e "${GREEN}Ansible installed successfully: ${ansible_version}${NC}"
    else
        echo -e "${RED}Error: Ansible installation failed${NC}"
        exit 1
    fi
}

# Execute installation steps
main() {
    check_root
    check_distro
    install_prerequisites
    install_ansible
    validate_installation
}

# Start the script
main