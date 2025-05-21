variable "vcenter_server" {
  type    = string
  default = ""
}
variable "host" {
  type    = string
  default = "localhost.localdomain"
}

variable "vcenter_username" {
  type    = string
  default = "root"
}

variable "vcenter_password" {
  type    = string
  default = ""
}

variable "datastore" {
  type    = string
  default = "datastore1"
}

variable "datacenter" {
  type    = string
  default = "localhost.localdomain"
}

variable "cluster" {
  type    = string
  default = "localhost.localdomain"
}

variable "network" {
  type    = string
  default = "VM Network"
}


################### ubuntu 24.04.2 ###################
variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/noble/ubuntu-24.04.2-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://releases.ubuntu.com/noble/SHA256SUMS"
}

variable "boot_command" {
  type = list(string)
  default = [
    "<wait>e<wait>",
    "<down><down><down><end> ",
    # "ip=IP::GATEWAY:SUBNET::INTERFACENAME:none ",  => FOR VMWARE IF DHCP IS NOT AVAILABLE
    "autoinstall ds=nocloud-net\\;",
    "s=http://{{.HTTPIP}}:{{.HTTPPort}}",
    "/ubuntu/",
    "<wait><f10><wait>"
  ]
}

################### login info ###################
variable "ssh_username" {
  type    = string
  default = "packer"
}

variable "ssh_password" {
  type    = string
  default = "packer"
}

################### vm config ###################
variable "cpus" {
  type    = number
  default = 10
}

variable "memory" {
  type    = number
  default = 20480
}

variable "disk_size" {
  type    = number
  default = 30720
}

variable "ssh_wait_timeout" {
  type    = string
  default = "30m"
}
variable "vm_name" {
  type    = string
  default = "ubuntu-golden"
}

