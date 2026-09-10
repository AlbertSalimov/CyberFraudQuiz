variable "image_family" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "platform_id" {
  type = string
}

variable "hostname" {
  type = string
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = number
}

variable "subnet_id" {
  type = string
}

variable "enable_nat" {
  type = bool
}

variable "ssh_user" {
  type = string
}

variable "ssh_pubkey_file" {
  type = string
}
