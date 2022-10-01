terraform {
    required_providers {
        libvirt = {
            source = "dmacvicar/libvirt"
            version = "0.6.14"
        }
    }
}

provider "libvirt" {
    #uri = "qemu+ssh://salim@192.168.68.108/system"
}

locals {
    controlplane = {
        user_data = file("${path.module}/controlplane/cloud-init.cfg")
    }
    worker1 = {
        user_data = file("${path.module}/worker1/cloud-init.cfg")
    }
    worker2 = {
        user_data = file("${path.module}/worker2/cloud-init.cfg")
    }
}

# resource "libvirt_pool" "k8s" {
#    name = "k8s"
#    type = "dir"
#    path = "/tmp/k8s-pool"
# }

resource "libvirt_network" "k8s_net" {
    name = "k8snet"
    mode = "nat"
    domain = "k8s.local"
    addresses = ["10.17.3.0/24", "2001:db8:ca2:2::1/64"]

    dns {
        enabled = true
        hosts {
            hostname = "k8s-controlplane"
            ip = "10.17.3.2"
        }
        hosts {
            hostname = "k8s-worker1"
            ip = "10.17.3.10"
        }
        hosts {
            hostname = "k8s-worker2"
            ip = "10.17.3.11"
        }
    }
}

resource "libvirt_cloudinit_disk" "cloudinit_controller" {
    name = "cloudinit-controller.iso"
    user_data = local.controlplane.user_data
}

resource "libvirt_cloudinit_disk" "cloudinit_worker1" {
    name = "cloudinit-worker1.iso"
    user_data = local.worker1.user_data
}

resource "libvirt_cloudinit_disk" "cloudinit_worker2" {
    name = "cloudinit-worker2.iso"
    user_data = local.worker2.user_data
}

resource "libvirt_volume" "ubuntu-qcow2-base" {
    name = "ubuntu"
    source = "https://cloud-images.ubuntu.com/minimal/releases/focal/release/ubuntu-20.04-minimal-cloudimg-amd64.img"
}

resource "libvirt_volume" "ubuntu-qcow2-controller" {
    name = "ubuntu-controller.qcow2"
    base_volume_id = libvirt_volume.ubuntu-qcow2-base.id  
    size =  53687091200
}

resource "libvirt_volume" "ubuntu-qcow2-worker1" {
    name = "ubuntu-worker1.qcow2"
    base_volume_id = libvirt_volume.ubuntu-qcow2-base.id
    size = 53687091200
}

resource "libvirt_volume" "ubuntu-qcow2-worker2" {
    name = "ubuntu-worker2.qcow2"
    base_volume_id = libvirt_volume.ubuntu-qcow2-base.id
    size = 53687091200
}

resource "libvirt_domain" "k8s-controlplane" {
    name = "k8s-controlplane"
    memory = "4096"
    vcpu = 4

    cloudinit = libvirt_cloudinit_disk.cloudinit_controller.id

    network_interface {
        network_id = libvirt_network.k8s_net.id
        addresses = ["10.17.3.2"]
    }

    disk {
        volume_id = "${libvirt_volume.ubuntu-qcow2-controller.id}"
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

resource "libvirt_domain" "k8s-worker1" {
    name = "k8s-worker1"
    memory = "4096"
    vcpu = 4

    cloudinit = libvirt_cloudinit_disk.cloudinit_worker1.id

    network_interface {
        network_id = libvirt_network.k8s_net.id
        addresses = ["10.17.3.10"]
    }

    disk {
        volume_id = "${libvirt_volume.ubuntu-qcow2-worker1.id}"
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

resource "libvirt_domain" "k8s-worker2" {
    name = "k8s-worker2"
    memory = "4096"
    vcpu = 4

    cloudinit = libvirt_cloudinit_disk.cloudinit_worker2.id

    network_interface {
        network_id = libvirt_network.k8s_net.id
        addresses = ["10.17.3.11"]
    }

    disk {
        volume_id = "${libvirt_volume.ubuntu-qcow2-worker2.id}"
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