terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_vpc_network" "this" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "this" {
  name           = var.subnet_name
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.cidr_block]
}
