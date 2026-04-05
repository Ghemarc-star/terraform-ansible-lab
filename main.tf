terraform {
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
}

resource "google_compute_network" "main_network" {
  name                    = "main-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main_subnet" {
  name          = "main-subnet"
  network       = google_compute_network.main_network.id
  region        = var.region
  ip_cidr_range = "10.0.0.0/16"
}

resource "google_container_cluster" "main_cluster" {
  name               = "main-cluster"
  location           = var.region
  initial_node_count = 3
  
  node_config {
    machine_type = "e2-small"
    disk_size_gb = 20
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  
  network    = google_compute_network.main_network.id
  subnetwork = google_compute_subnetwork.main_subnet.id
  
  deletion_protection = false
}

output "cluster_name" {
  value = google_container_cluster.main_cluster.name
}

output "cluster_location" {
  value = google_container_cluster.main_cluster.location
}
