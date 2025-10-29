# GCP Flarum Infrastructure - Terraform Configuration
# Optimized for Free Tier compliance

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "db_password" {
  description = "Database password for Flarum"
  type        = string
  sensitive   = true
}

# VPC Network
resource "google_compute_network" "flarum_network" {
  name                    = "flarum-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "flarum_subnet" {
  name          = "flarum-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.flarum_network.id
}

# Firewall rules
resource "google_compute_firewall" "flarum_http" {
  name    = "flarum-http"
  network = google_compute_network.flarum_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["flarum-web"]
}

resource "google_compute_firewall" "flarum_ssh" {
  name    = "flarum-ssh"
  network = google_compute_network.flarum_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["flarum-web"]
}

# Cloud SQL MySQL instance (Free Tier: db-f1-micro)
resource "google_sql_database_instance" "flarum_db" {
  name             = "flarum-db"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    
    disk_size = 10
    disk_type = "PD_HDD"
    
    backup_configuration {
      enabled = false
    }
    
    maintenance_window {
      day = 7
      hour = 3
    }
    
    ip_configuration {
      ipv4_enabled = true
    }
  }
}

# Database
resource "google_sql_database" "flarum" {
  name     = "flarum"
  instance = google_sql_database_instance.flarum_db.name
}

# Database user
resource "google_sql_user" "flarum_user" {
  name     = "flarum"
  instance = google_sql_database_instance.flarum_db.name
  password = var.db_password
}

# Compute instance (Free Tier: e2-micro with performance pool)
resource "google_compute_instance" "flarum_vm" {
  name         = "flarum-vm"
  machine_type = "e2-micro"
  zone         = var.zone
  
  # Enable performance pool for better CPU performance
  scheduling {
    preemptible = false
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.flarum_network.id
    subnetwork = google_compute_subnetwork.flarum_subnet.id
    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["flarum-web"]

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/../ansible/flarum_devops.pub")}"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    
    # Ensure SSH is running and configured
    systemctl enable ssh
    systemctl start ssh
    
    # Configure SSH for better connectivity
    sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 60/' /etc/ssh/sshd_config
    sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 10/' /etc/ssh/sshd_config
    sed -i 's/#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config
    systemctl restart ssh
    
    # Update package lists (lightweight)
    apt-get update
    
    # Basic system setup (non-blocking)
    apt-get install -y wget curl git python3 || true
    
    # Signal that startup is complete
    echo "VM startup completed successfully" > /tmp/startup-complete
  EOF
}

# Outputs for Ansible
output "vm_ip" {
  description = "VM external IP address"
  value       = google_compute_instance.flarum_vm.network_interface[0].access_config[0].nat_ip
}

output "db_host" {
  description = "Database host IP"
  value       = google_sql_database_instance.flarum_db.ip_address[0].ip_address
}

output "db_name" {
  description = "Database name"
  value       = google_sql_database.flarum.name
}

output "db_user" {
  description = "Database username"
  value       = google_sql_user.flarum_user.name
}
