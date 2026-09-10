module "vpc" {
  source = "./modules/vpc"

  network_name = var.network_name
  subnet_name  = var.subnet_name
  zone         = var.zone
  cidr_block   = var.cidr_block
}

module "compute" {
  source = "./modules/compute"

  image_family    = var.image_family
  instance_name   = var.instance_name
  platform_id     = var.platform_id
  hostname        = var.hostname
  cores           = var.cores
  memory          = var.memory
  disk_size       = var.disk_size
  subnet_id       = module.vpc.subnet_id
  enable_nat      = var.enable_nat
  ssh_user        = var.ssh_user
  ssh_pubkey_file = var.ssh_pubkey_file
}
