terraform {
  backend "remote" {
    organization = "HashicorpAndRedHat"

    workspaces {
      name = "gcp-self-service-demo"
    }
  }
}

provider "google" {
  region     = var.gcp_region
}

resource "google_compute_network" "cloud-deploy-vpc" {
  name = "${var.gcp_prefix}-vpc"
  auto_create_subnetworks = "false"
}


resource "google_compute_firewall" "cloud-deploy-firewall" {
  name        = "${var.gcp_prefix}-firewall"
  network      = google_compute_network.cloud-deploy-vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8200", "3306"]
  }

  target_tags = ["appdeployment", var.application]
}

resource "google_compute_subnetwork" "cloud-deploy-subnet" {
  name = "${var.gcp_prefix}-subnet"
  network = google_compute_network.cloud-deploy-vpc.name
  ip_cidr_range = "192.168.0.0/28"
}

resource "tls_private_key" "cloud-deploy-tls-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "file" {
    content      = tls_private_key.cloud-deploy-tls-private-key.private_key_pem
    destination = "/tmp/${var.gcp_prefix}-key-private.pem"

    connection {
      type     = "ssh"
      user     = "${var.tower_ssh_username}"
      private_key = "${var.tower_ssh_key}"
      host     = "${var.tower_hostname}"
    }
  }

  provisioner "file" {
    content      = tls_private_key.cloud-deploy-tls-private-key.public_key_openssh
    destination = "/tmp/${var.gcp_prefix}-key.pub"

    connection {
      type     = "ssh"
      user     = "${var.tower_ssh_username}"
      private_key = "${var.tower_ssh_key}"
      host     = "${var.tower_hostname}"
    }
  }
}

resource "google_compute_instance" "cloud-deploy-webservers" {
  count = var.num_instances
  name         = "${var.gcp_prefix}-webserver-${count.index + 1}"
  machine_type = var.machine_type
  zone = "us-central1-a"
  tags = [var.application, "appdeployment"]
  boot_disk {
    device_name = "${var.gcp_prefix}-disk-${count.index + 1}"
    auto_delete = "true"
    initialize_params {
      size = "20"
      image = var.gcp_disk_image
    }
  }
  metadata = {
    ssh-keys = "ec2-user:${tls_private_key.cloud-deploy-tls-private-key.public_key_openssh} ec2-user"
  }
  labels = {
    provisioner = "mford"
    application = var.application
    demo = "appdeployment"
    group = "rhel"
    cloud_provider = "gcp"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.cloud-deploy-subnet.name
    access_config {}
  }
}

resource "google_compute_instance" "cloud-deploy-secrets-engine" {
  count = 1
  name         = "secret-engine-server"
  machine_type = "n1-standard-1"
  zone = "us-central1-a"
  tags = [var.application, "appdeployment"]
  boot_disk {
    device_name = "${var.gcp_prefix}-webserver-disk"
    auto_delete = "true"
    initialize_params {
      size = "20"
      image = var.gcp_disk_image
    }
  }
  metadata = {
    ssh-keys = "ec2-user:${tls_private_key.cloud-deploy-tls-private-key.public_key_openssh} ec2-user"
  }
  labels = {
    provisioner = "mford"
    application = var.application
    demo = "appdeployment"
    group = "webserver"
    cloud_provider = "gcp"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.cloud-deploy-subnet.name
    access_config {}
  }
}
