terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.138.0"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = "y0__xCcu8k0GMHdEyDjwJmlEr_7y2U0_5Z1Y9SiPrZq47s3BIiQ"
  cloud_id  = "b1gb7k3fvm0ad0euembe"
  folder_id = "b1gfg86189j3v8nosfbs"
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "default" {
  name        = "vm1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd85hkli5dp6as39ali4"
    }
  }
  
  network_interface {
    index     = 0
    subnet_id = yandex_vpc_subnet.foo.id
    nat = true
  }

  metadata = {
    foo      = "bar"
    user-data = "${file("cloud-init.yaml")}"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_vpc_network" "foo" {}

resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

output "vm_ip" {
  value = yandex_compute_instance.default.network_interface[0].nat_ip_address
}
