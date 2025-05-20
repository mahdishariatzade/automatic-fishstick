#!/bin/bash

# ----------------------------
# Configuration
# ----------------------------
PACKER_VERSION="latest"
VBOX_VERSION="7.1"
DEBIAN_CODENAME="$(lsb_release -cs)"
VBOX_REPO_URL="https://download.virtualbox.org/virtualbox/debian"
VBOX_EXT_VERSION=""
VMWARE_BUNDLE_NAME="VMware-Player-FULL-*.x86_64.bundle"
VMWARE_BUNDLE_PATH="/tmp/$VMWARE_BUNDLE_NAME"



# ----------------------------
# Check for root privileges
# ----------------------------
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Prompt user to choose which components to install
read -n1 -p "Install build dependencies? [Y/n] " install_deps_ans; echo
if [[ "$install_deps_ans" =~ ^(N|n)$ ]]; then SKIP_DEPENDENCIES=true; fi

read -n1 -p "Install Packer? [Y/n] " install_packer_ans; echo
if [[ "$install_packer_ans" =~ ^(N|n)$ ]]; then SKIP_PACKER=true; fi

read -n1 -p "Install VirtualBox? [Y/n] " install_vbox_ans; echo
if [[ "$install_vbox_ans" =~ ^(N|n)$ ]]; then SKIP_VBOX=true; fi

read -n1 -p "Install VMware Workstation Player? [Y/n] " install_vmware_ans; echo
if [[ "$install_vmware_ans" =~ ^(N|n)$ ]]; then SKIP_VMWARE=true; fi

echo "[+] Updating system packages"
apt update && apt upgrade -y

# ----------------------------
# Install dependencies
# ----------------------------
if [ -z "$SKIP_DEPENDENCIES" ]; then
  echo "[+] Installing build dependencies"
  apt install -y \
      curl wget unzip gnupg2 software-properties-common apt-transport-https \
      linux-headers-$(uname -r) dkms gcc make build-essential
else
  echo "[~] Skipping build dependencies"
fi

# ----------------------------
# Install Packer
# ----------------------------
if [ -z "$SKIP_PACKER" ]; then
  echo "[+] Installing HashiCorp Packer"

  curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${DEBIAN_CODENAME} main" \
      > /etc/apt/sources.list.d/hashicorp.list

  apt update
  apt install -y packer
  packer --version && echo "[✔] Packer installed successfully"
else
  echo "[~] Skipping Packer installation"
fi

# ----------------------------
# Install VirtualBox
# ----------------------------
if [ -z "$SKIP_VBOX" ]; then
  echo "[+] Installing VirtualBox package"
  apt install -y virtualbox-$VBOX_VERSION

  # Install VirtualBox Extension Pack from official site
  VBOX_EXT_VERSION=$(vboxmanage --version | cut -dr -f1)
  EXT_PACK_NAME="Oracle_VirtualBox_Extension_Pack-${VBOX_EXT_VERSION}.vbox-extpack"
  EXT_PACK_URL="https://download.virtualbox.org/virtualbox/${VBOX_EXT_VERSION}/${EXT_PACK_NAME}"
  EXT_PACK_PATH="/tmp/${EXT_PACK_NAME}"

  echo "[+] Downloading Extension Pack: ${EXT_PACK_NAME}"
  wget --show-progress -O "${EXT_PACK_PATH}" "${EXT_PACK_URL}"

  if [[ ! -s "${EXT_PACK_PATH}" ]]; then
    echo "❌ Download failed or file is empty. Please check your internet connection or VirtualBox version."
    exit 1
  fi

  echo "[+] Installing Extension Pack..."
  vboxmanage extpack install --replace "${EXT_PACK_PATH}"

  if [[ $? -ne 0 ]]; then
    echo "❌ Extension Pack installation failed. The file might be corrupted."
    echo "You can manually download it from:"
    echo "  ${EXT_PACK_URL}"
    exit 1
  fi

  rm -f "${EXT_PACK_PATH}"
  echo "[✔] Extension Pack installed successfully."
else
  echo "[~] Skipping VirtualBox installation"
fi

# ----------------------------
# VMware Workstation Player
# ----------------------------
if [ -z "$SKIP_VMWARE" ]; then
  echo "[+] Downloading VMware Workstation Pro ZIP"
  VMWARE_ZIP_URL="https://dl2.soft98.ir/linux/VMware.Workstation.Pro.17.6.1.Linux.zip?1747658786"
  VMWARE_ZIP_PATH="/tmp/VMware.Workstation.Pro.17.6.1.Linux.zip"
  wget --show-progress -O "$VMWARE_ZIP_PATH" "$VMWARE_ZIP_URL"
  if [[ ! -s "$VMWARE_ZIP_PATH" ]]; then
    echo "❌ Failed to download VMware ZIP."
    exit 1
  fi
  EXTRACT_DIR="/tmp/vmware_zip"
  mkdir -p "$EXTRACT_DIR"
  echo "[+] Extracting VMware ZIP with password..."
  unzip -q -P "soft98.ir" "$VMWARE_ZIP_PATH" -d "$EXTRACT_DIR"

  # Navigate into the extracted version directory
  ZIP_SUBDIR="VMware.Workstation.Pro.17.6.1.Linux"
  EXTRACT_SUBDIR="$EXTRACT_DIR/$ZIP_SUBDIR"
  BUNDLE_TAR=$(find "$EXTRACT_SUBDIR" -type f -name "*.bundle.tar" | head -n 1)
  if [[ -z "$BUNDLE_TAR" ]]; then
    echo "❌ bundle.tar not found in the extracted files."
    exit 1
  fi
  echo "[+] Extracting bundle.tar..."
  tar -xf "$BUNDLE_TAR" -C "$EXTRACT_SUBDIR"
  INSTALLER=$(find "$EXTRACT_SUBDIR" -type f -name "*.bundle" | head -n 1)
  if [[ -z "$INSTALLER" ]]; then
    echo "❌ VMware installer bundle not found after extraction."
    exit 1
  fi
  chmod +x "$INSTALLER"
  echo "[+] Running VMware installer: $INSTALLER"
  "$INSTALLER" --console --required --eulas-agreed
  echo "[✔] VMware Workstation Pro installed successfully."
else
  echo "[~] Skipping VMware Workstation Player installation"
fi

# ----------------------------
# Done
# ----------------------------
echo
echo "Installation summary:"
if [ -z "$SKIP_PACKER" ]; then echo " - Packer version: $(packer --version)"; else echo " - Packer: skipped"; fi
if [ -z "$SKIP_VBOX" ]; then echo " - VirtualBox version: $(vboxmanage --version)"; else echo " - VirtualBox: skipped"; fi
if [ -z "$SKIP_VMWARE" ]; then echo " - VMware Player installed (binary: /usr/bin/vmplayer)"; else echo " - VMware Player: skipped"; fi
