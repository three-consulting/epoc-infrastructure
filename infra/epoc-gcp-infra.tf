variable "environment" {
  type = string
}

locals {
  instance_name        = "epoc-${var.environment}-database"
  private_network_name = "epoc-${var.environment}-private-network"
  private_ip_name      = "epoc-${var.environment}-private-ip"
  region               = "europe-north1"
  zone                 = "europe-north1-a"
  project              = var.environment == "prod" ? "epoc-auth" : "epoc-auth-dev-361109"
}

provider "google" {
  credentials = var.environment == "prod" ? file("../epoc-terraform-sa-prod.json") : file("../epoc-terraform-sa-dev.json")
  project     = local.project
  region      = local.region
}

provider "google-beta" {
  credentials = var.environment == "prod" ? file("../epoc-terraform-sa-prod.json") : file("../epoc-terraform-sa-dev.json")
  project     = local.project
  region      = local.region
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.57.0"
    }
  }
}

resource "google_compute_network" "private_network" {
  provider = google-beta
  name     = local.private_network_name
}

# Reserve global internal address range for the peering
resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  name          = local.private_ip_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.self_link
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.private_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Create serverless vpc connector to connect db
resource "google_vpc_access_connector" "connector" {
  provider      = google
  name          = "epoc-${var.environment}-vpc-connector"
  ip_cidr_range = "10.40.0.0/28"
  network       = local.private_network_name
  machine_type  = "e2-micro"
}

# Create postgres DB
resource "google_sql_database_instance" "epoc_database" {
  provider         = google
  database_version = "POSTGRES_15"
  name             = local.instance_name
  project          = local.project
  region           = local.region

  settings {
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"

    backup_configuration {
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }

      start_time                     = "16:00"
      transaction_log_retention_days = 7
    }

    database_flags {
      name  = "max_connections"
      value = "50"
    }

    disk_autoresize       = false
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_SSD"

    insights_config {
      query_string_length = 1024
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = "projects/${local.project}/global/networks/${local.private_network_name}"
    }

    location_preference {
      zone = local.zone
    }

    pricing_plan = "PER_USE"
    tier         = "db-f1-micro"

    user_labels = {
      environment = "${var.environment}"
    }
  }
}

# Create artifact registry
resource "google_artifact_registry_repository" "epoc_prod_container_repository" {
  provider = google
  format   = "DOCKER"

  labels = {
    environment = "${var.environment}"
  }
  location      = local.region
  project       = local.project
  repository_id = "epoc-${var.environment}-container-repository"
}