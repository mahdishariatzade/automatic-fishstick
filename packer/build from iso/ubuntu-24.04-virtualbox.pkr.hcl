// Simple Packer template for VirtualBox
packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = "~> 1"
      source  = "github.com/hashicorp/vagrant"
    }
    vsphere = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vsphere"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}


source "vsphere-iso" "vsphere-ubuntu" {
  ### vsphere config ###
  vcenter_server = var.vcenter_server
  host = var.host
  vm_name = var.vm_name
  username       = var.vcenter_username
  password       = var.vcenter_password
  # cluster   = var.cluster # Host name if ESXi standalone
  datastore = var.datastore


  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }
  export {
      force = true
      output_directory = "./output-artifacts"
    }

  insecure_connection = true # if using SSL without CA
  guest_os_type = "ubuntu64Guest"
  iso_url       = var.iso_url
  iso_checksum  = var.iso_checksum

  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_wait_timeout = var.ssh_wait_timeout

  boot_keygroup_interval = "0.3s"
  boot_command = var.boot_command


  CPUs = var.cpus
  RAM  = var.memory
  storage {
    disk_size = var.disk_size
  }

  http_directory         = "./http"
  ssh_handshake_attempts = 30
}



source "virtualbox-iso" "virtualbox-ubuntu" {

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  http_directory         = "./http"
  boot_keygroup_interval = "1s"
  boot_command           = var.boot_command

  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_wait_timeout = var.ssh_wait_timeout

  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  guest_os_type    = "Ubuntu_64"
  vm_name          = var.vm_name

  cpus      = var.cpus      // Number of virtual CPUs
  memory    = var.memory    // RAM in MB
  disk_size = var.disk_size // Disk size in MB (45GB)

  headless = false // Keeping headless false is good for debugging boot issues
}

build {
  name = "ubuntu-24.04-virtualbox"
  hcp_packer_registry {
    bucket_name = "ubuntu-24-04-vmware"
    description = "Ubuntu 24.04 vmware"
    bucket_labels = {
      "os"      = "ubuntu"
      "type"    = "vmware"
      "version" = "24.04"
    }
    build_labels = {
      "build-time" = timestamp()
    }
  }
  sources = [
    # "source.virtualbox-iso.virtualbox-ubuntu",
    "source.vsphere-iso.vsphere-ubuntu"
  ]

  provisioner "shell" {
    inline = ["echo 'hello'"]
  }

  provisioner "ansible" {
      playbook_file = "playbook-01.yml"
    }
  post-processor "vagrant" {
    keep_input_artifact = false
    output              = "ubuntu-24.04-virtualbox.box"
  }
} 