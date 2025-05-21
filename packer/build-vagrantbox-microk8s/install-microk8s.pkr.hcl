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
  source_path  = var.source_path
  skip_add     = true
}

// Insert a new vagrant source block for VMware
source "vagrant" "ubuntu-vmware" {
  communicator = "ssh"
  provider     = "vmware_desktop"
  source_path  = va
  skip_add     = true
}

build {
  sources = [
    "source.vagrant.ubuntu-virtualbox",
    # "source.vagrant.ubuntu-vmware",
  ]

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    use_proxy     = false
    ansible_env_vars = [
      "ANSIBLE_CONFIG=./ansible.cfg",
    ]
    extra_arguments = [
      "--extra-vars", "microk8s_version=${var.version}/stable"
    ]
  }

  post-processor "vagrant-registry" {
    client_id     = "${var.hcp_client_id}"
    client_secret = "${var.hcp_client_secret}"
    box_tag       = "${var.box_tag}"
    version       = "${var.version}"
    architecture  = "${var.architecture}"
  }
}
