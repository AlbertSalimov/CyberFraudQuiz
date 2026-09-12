variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "cidr_block" {
  type = string
}

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

variable "enable_nat" {
  type = bool
}

variable "ssh_user" {
  type = string
}

variable "ssh_pubkey_file" {
  type = string
}

variable "service_account_key_file" {
  type = string
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}
