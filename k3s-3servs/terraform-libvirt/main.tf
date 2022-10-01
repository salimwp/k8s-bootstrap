terraform {
    required_providers {
        libvirt = {
            source = "dmacvicar/libvirt"
            version = "0.6.14"
        }
    }
}

provider "libvirt" {
    #uri = "driver+ssh://salim@192.168.68.108/system"
}

locals {
    dev = {
        user_data = file("${path.module}/dev/cloud-init.cfg")
    }
    stage = {
        user_data = file("${path.module}/stage/cloud-init.cfg")
    }
    prod = {
        user_data = file("${path.module}/prod/cloud-init.cfg")
    }
}

resource "libvirt_network" "k8s_net" {
    name = "k3snet"
    mode = "nat"
    domain = "k3s.local"
    addresses = ["10.17.3.0/24", "2001:db8:ca2:2::1/64"]

    dns {
        enabled = true
        hosts {
            hostname = "k3s-dev"
            ip = "10.17.3.2"
        }
        hosts {
            hostname = "k8s-stage"
            ip = "10.17.3.10"
        }
        hosts {
            hostname = "k8s-prod"
            ip = "10.17.3.11"
        }
    }
}

resource "libvirt_cloudinit_disk" "cloudinit_dev" {
    name = "cloudinit-dev.iso"
    user_data = local.dev.user_data
}

resource "libvirt_cloudinit_disk" "cloudinit_stage" {
    name = "cloudinit-stage.iso"
    user_data = local.stage.user_data
}

resource "libvirt_cloudinit_disk" "cloudinit_prod" {
    name = "cloudinit-prod.iso"
    user_data = local.prod.user_data
}

resource "libvirt_volume" "ubuntu-qcow2-base" {
    name = "ubuntu"
    source = "https://cloud-images.ubuntu.com/minimal/releases/focal/release/ubuntu-20.04-minimal-cloudimg-amd64.img"
}

resource "libvirt_volume" "ubuntu-qcow2-dev" {
    name = "ubuntu-dev.qcow2"
    base_volume_id = libvirt_volume.ubuntu-qcow2-base.id  
    size =  53687091200
}

resource "libvirt_volume" "ubuntu-qcow2-stage" {
    name = "ubuntu-stage.qcow2"
    base_volume_id = libvirt_volume.ubuntu-qcow2-base.id
    size = 53687091200
}

resource "libvirt_volume" "ubuntu-qcow2-prod" {
    name = "ubuntu-prod.qcow2"
    base_volume_id = libvirt_volume.ubuntu-qcow2-base.id
    size = 53687091200
}

resource "libvirt_domain" "k3s-dev" {
    name = "k3s-dev"
    memory = "4096"
    vcpu = 4

    cloudinit = libvirt_cloudinit_disk.cloudinit_dev.id

    network_interface {
        network_id = libvirt_network.k8s_net.id
        addresses = ["10.17.3.2"]
    }

    disk {
        volume_id = "${libvirt_volume.ubuntu-qcow2-dev.id}"
    }

    console {
        type = "pty"
        target_type = "serial"
        target_port = "0"
        source_path = "/dev/pts/4"
    }

    graphics {
        type = "vnc"
        listen_type = "address"
    }
}

resource "libvirt_domain" "k8s-stage" {
    name = "k8s-stage"
    memory = "4096"
    vcpu = 4

    cloudinit = libvirt_cloudinit_disk.cloudinit_stage.id

    network_interface {
        network_id = libvirt_network.k8s_net.id
        addresses = ["10.17.3.10"]
    }

    disk {
        volume_id = "${libvirt_volume.ubuntu-qcow2-stage.id}"
    }

    console {
        type = "pty"
        target_type = "serial"
        target_port = "0"
        source_path = "/dev/pts/4"
    }

    graphics {
        type = "vnc"
        listen_type = "address"
    }
}

resource "libvirt_domain" "k8s-prod" {
    name = "k8s-prod"
    memory = "4096"
    vcpu = 4

    cloudinit = libvirt_cloudinit_disk.cloudinit_prod.id

    network_interface {
        network_id = libvirt_network.k8s_net.id
        addresses = ["10.17.3.11"]
    }

    disk {
        volume_id = "${libvirt_volume.ubuntu-qcow2-prod.id}"
    }

    console {
        type = "pty"
        target_type = "serial"
        target_port = "0"
        source_path = "/dev/pts/4"
    }

    graphics {
        type = "vnc"
        listen_type = "address"
    }
}