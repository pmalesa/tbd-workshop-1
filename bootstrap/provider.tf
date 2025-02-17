provider "google" {
  project = local.project
  region  = var.region
}
terraform {
  required_version = "~> 1.9.0"
  required_providers {
    google = {
      version = "~> 5.44.0"
    }
  }
}