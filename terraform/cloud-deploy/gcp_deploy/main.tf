provider "google" {
  region     = "us-central1"
  project    = var.gcp_project
  credentials = var.gcp_key
}

resource "google_compute_network" "mford-linux-vpc" {
  auto_create_subnetworks = "false"
  name = "mford-linux-vpc"
}


resource "google_compute_firewall" "mford-linux-firewall" {
  name        = "mford-linux-firewall"
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
  name = "mford-linux-subnet"
  network = google_compute_network.mford-linux-vpc.name
  ip_cidr_range = "192.168.0.0/28"
}

resource "tls_private_key" "mford-linux-tls-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "webservers" {
  count = var.num_instances
  name         = "apache-server-${count.index + 1}"
  machine_type = var.machine_type
  zone = "us-central1-a"
  tags = ["apache", "appdeployment"]
  boot_disk {
    device_name = "mford-linux-disk-${count.index + 1}"
    auto_delete = "true"
    initialize_params {
      size = "20"
      image = var.gcp_disk_image
    }
  }
  metadata = {
    ssh-keys = "ec2-user:tls_private_key.mford-linux-tls-private-key.public_key_openssh ec2-user"
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
    device_name = "mford-linux-webserver-disk"
    auto_delete = "true"
    initialize_params {
      size = "20"
      image = var.gcp_disk_image
    }
  }
  metadata = {
    ssh-keys = "ec2-user:tls_private_key.mford-linux-tls-private-key.public_key_openssh ec2-user"
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

resource "local_file" "foo" {
    content          = tls_private_key.mford-linux-tls-private-key.private_key_pem
    filename         = "/tmp/mford-linux-key-private.pem"
    file_permission  = "0600"
}
