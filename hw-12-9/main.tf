terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = "y0_AgAAAABEezXuAATuwQAAAADXV8wjHipDbw-1ScaUnNdqKClO2Z3Ykoo"
  cloud_id = "b1gm7bp2grqbho73ke1l"
  folder_id = "b1g7l8ost873t9a9r3g3"
}
resource "yandex_mdb_postgresql_cluster" "golikov-hw-12-9-2" {
  name                = "hw-12-9-2"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.network-1.id
  security_group_ids  = [ yandex_vpc_security_group.pgsql-sg.id ]
  deletion_protection = false

  config {
    version = 14
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = "20"
    }
  }

  host {
    zone      = "ru-central1-a"
    name      = "hw-12-9-pg-host-a"
    subnet_id = yandex_vpc_subnet.subnet-1.id
    assign_public_ip = true
  }
  host {
    zone      = "ru-central1-b"
    name      = "hw-12-9-pg-host-b"
    subnet_id = yandex_vpc_subnet.subnet-2.id
    assign_public_ip = true
  }  
}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}
resource "yandex_vpc_security_group" "pgsql-sg" {
  name       = "pgsql-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description    = "PostgreSQL"
    port           = 6432
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}
resource "yandex_mdb_postgresql_database" "hw-12-9-2" {
  cluster_id = yandex_mdb_postgresql_cluster.golikov-hw-12-9-2.id
  name       = "hw-12-9-2"
  owner      = "golpa"
}
resource "yandex_mdb_postgresql_user" "golpa" {
  cluster_id = yandex_mdb_postgresql_cluster.golikov-hw-12-9-2.id
  name       = "golpa"
  password   = "golpagolpa"
}