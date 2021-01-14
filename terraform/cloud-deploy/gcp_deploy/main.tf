provider "google" {
  region     = var.gcp_region
  project    = var.gcp_project
  credentials = var.gcp_key
}

resource "google_compute_network" "mford-linux-vpc" {
  name = "mford-linux-vpc"
  auto_create_subnetworks = "false"
}


resource "google_compute_firewall" "mford-linux-firewall" {
  name        = "${gcp_prefix}-firewall"
  network      = google_compute_network.mford-linux-vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8200", "3306"]
  }

  target_tags = ["appdeployment", "apache"]
}

resource "google_compute_subnetwork" "mford-linux-subnet" {
  name = "${gcp_prefix}-subnet"
  network = google_compute_network.mford-linux-vpc.name
  ip_cidr_range = "192.168.0.0/28"
}

resource "tls_private_key" "mford-linux-tls-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "webservers" {
  count = var.num_instances
  name         = "${gcp_prefix}-server-${count.index + 1}"
  machine_type = var.machine_type
  zone = "us-central1-a"
  tags = ["apache", "appdeployment"]
  boot_disk {
    device_name = "${gcp_prefix}-disk-${count.index + 1}"
    auto_delete = "true"
    initialize_params {
      size = "20"
      image = var.gcp_disk_image
    }
  }
  metadata = {
    ssh-keys = "ec2-user:${tls_private_key.mford-linux-tls-private-key.public_key_openssh} ec2-user"
  }
  labels = {
    provisioner = "mford"
    application = "apache"
    demo = "appdeployment"
    group = "rhel"
    cloud_provider = "gcp"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.mford-linux-subnet.name
    access_config {}
  }
}

resource "google_compute_instance" "secret_engine" {
  count = 1
  name         = "secret-engine-server"
  machine_type = "n1-standard-1"
  zone = "us-central1-a"
  tags = ["apache", "appdeployment"]
  boot_disk {
    device_name = "${gcp_prefix}-webserver-disk"
    auto_delete = "true"
    initialize_params {
      size = "20"
      image = var.gcp_disk_image
    }
  }
  metadata = {
    ssh-keys = "ec2-user:${tls_private_key.mford-linux-tls-private-key.public_key_openssh} ec2-user"
  }
  labels = {
    provisioner = "mford"
    application = "apache"
    demo = "appdeployment"
    group = "webserver"
    cloud_provider = "gcp"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.mford-linux-subnet.name
    access_config {}
  }
}

resource "local_file" "private_key" {
    content          = tls_private_key.mford-linux-tls-private-key.private_key_pem
    filename         = "/tmp/id_ssh_rsa"
    file_permission  = "0600"
}

resource "local_file" "public_key" {
    content          = tls_private_key.mford-linux-tls-private-key.public_key_openssh
    filename         = "/tmp/id_ssh_rsa.pub"
    file_permission  = "0600"
}
