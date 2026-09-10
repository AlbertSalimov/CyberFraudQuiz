terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

data "yandex_compute_image" "this" {
  family = var.image_family
}

resource "yandex_compute_instance" "this" {
  name        = var.instance_name
  platform_id = var.platform_id
  hostname    = var.hostname

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.this.id
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.enable_nat
  }

  metadata = {
    ssh-keys = "$(var.ssh_user):${file(var.ssh_pubkey_file)}"
  }
}
