variable "environment" {
  type = string
}

variable "FIREBASE_SERVICE_ACCOUNT_JSON" {
  type = string
}

variable "SPRING_DATASOURCE_PASSWORD" {
  type = string
}

variable "SPRING_DATASOURCE_USERNAME" {
  type = string
}

variable "SPRING_DATASOURCE_URL" {
  type = string
}

variable "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI" {
  type = string
}

variable "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI" {
  type = string
}

locals {
  region = "europe-north1"
  project = var.environment == "prod" ? "epoc-auth" : "epoc-auth-dev-361109"
}

output "ENV" {
  value = local.project
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
      version = "4.0.0"
    }
  }
}

module "secret-manager" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "~> 0.1"
  project_id = local.project
  secrets = [
    {
      name                  = "FIREBASE_SERVICE_ACCOUNT_JSON"
      automatic_replication = false
      secret_data           = var.FIREBASE_SERVICE_ACCOUNT_JSON
    },
    {
      name                  = "SPRING_DATASOURCE_PASSWORD"
      automatic_replication = true
      secret_data           = var.SPRING_DATASOURCE_PASSWORD
    },
    {
      name                  = "SPRING_DATASOURCE_USERNAME"
      automatic_replication = true
      secret_data           = var.SPRING_DATASOURCE_USERNAME
    },
    {
      name                  = "SPRING_DATASOURCE_URL"
      automatic_replication = true
      secret_data           = var.SPRING_DATASOURCE_URL
    },
    # Note: command line environment variables cannot contain dashes (-)
    {
      name                  = "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK-SET-URI"
      automatic_replication = true
      secret_data           = var.SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI
    },
    {
      name                  = "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER-URI"
      automatic_replication = true
      secret_data           = var.SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI
    }
  ]
}
