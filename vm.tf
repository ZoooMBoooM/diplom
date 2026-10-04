data "yandex_compute_image" "debian" {
  family = "ubuntu-2404-lts-oslogin"
}

resource "yandex_compute_instance" "vm" {
  name        = "diplom-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/id_ed25519.pub")}"
  }
}
