resource "yandex_vpc_network" "net" {
  name = "diplom-net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "diplom-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
