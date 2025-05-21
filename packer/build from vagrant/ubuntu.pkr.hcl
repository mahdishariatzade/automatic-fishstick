// Simple Packer template for VirtualBox
packer {
  required_plugins {
    vagrant = {
      version = "~> 1"
      source  = "github.com/hashicorp/vagrant"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "vagrant" "ubuntu-virtualbox" {
  communicator = "ssh"
  provider     = "virtualbox"
  source_path  = "bento/ubuntu-24.04"
  skip_add     = var.skip_add
}

// Insert a new vagrant source block for VMware
source "vagrant" "ubuntu-vmware" {
  communicator = "ssh"
  provider     = "vmware_desktop"
  source_path  = "bento/ubuntu-24.04"
  skip_add     = var.skip_add
}

build {
  sources = [
    "source.vagrant.ubuntu-virtualbox",
    # "source.vagrant.ubuntu-vmware",
  ]

  provisioner "shell" {
    inline = ["echo 'hello'"]
  }

  post-processor "shell-local" {
    inline = ["echo Doing stuff..."]
  }

  post-processor "vagrant-registry" {
    client_id     = "${var.hcp_client_id}"
    client_secret = "${var.hcp_client_secret}"
    box_tag       = "${var.box_tag}"
    version       = "${var.version}"
    architecture  = "${var.architecture}"
  }
}
