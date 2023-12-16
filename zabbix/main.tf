/* Основной файл проекта. В нем указывается версия terraform, на которой будет работать проект, провайдер ресурсов, и сами ресурсы.
*/

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex" #  глобальный адрес источника провайдера.
    }
  }
  required_version = ">= 0.13" # минимальная версия Terraform, с которой совместим провайдер
}

#  Название провайдера и зона доступности, в которой по умолчанию будут создоватся все облочные ресурсы.

provider "yandex" {

  token     = var.do_token
  cloud_id  = var.do_cloud_id
  folder_id = var.do_folder_id
}

# настройки провайдера
# вирт1
resource "yandex_compute_instance" "zabbix" {
  name                      = "zabbix"
  hostname                  = "zabbix.s-lebedev"
  allow_stopping_for_update = true
  platform_id               = "standard-v2"
  zone                      = var.do_zone_a

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd8clogg1kull9084s9o"
    }
  }

  metadata = {
    user-data = "${file("~/terraform/meta.txt")}"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-zabbix.id
    nat       = true
  }

  connection {
    type        = "ssh"
    user        = "s.lebedev"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.network_interface[0].nat_ip_address
    timeout     = "60s"
  }

  provisioner "file" {
    source      = "nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "file" {
    source      = "zabbix_server.conf"
    destination = "/tmp/zabbix_server.conf"
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh",
      "sudo rm /tmp/install.sh"
    ]
  }

}

# сеть
resource "yandex_vpc_network" "network-zabbix" {
  name = "network_zabbix"
}

resource "yandex_vpc_subnet" "subnet-zabbix" {
  name           = "subnet_zabbix"
  zone           = var.do_zone_a
  network_id     = yandex_vpc_network.network-zabbix.id
  v4_cidr_blocks = ["192.168.0.0/24"]
}

output "internal_ip_address_vm_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}


output "external_ip_address_vm_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}