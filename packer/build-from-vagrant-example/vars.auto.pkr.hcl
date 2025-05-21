variable "hcp_client_id" {
  type    = string
}

variable "hcp_client_secret" {
  type    = string
}
variable "version" {
  type    = string
  default = "1.0.0"
}
variable "architecture" {
  type = string
  default = "amd64"
}
variable "box_tag" {
  type    = string
}

variable "skip_add" {
  type    = bool
  default = false
}
