variable "hcp_client_id" {
  type = string
}

variable "hcp_client_secret" {
  type = string
}

variable "source_path" {
  type    = string
  default = "bento/ubuntu-24.04"
}

variable "version" {
  type    = string
  default = "1.33"
}
variable "architecture" {
  type    = string
  default = "amd64"
}
variable "box_tag" {
  type = string
}