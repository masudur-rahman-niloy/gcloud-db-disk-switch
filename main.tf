variable "region" {
  description = "region resources will be deployed to"
}

variable "zone" {
  description = "zone resources will be deployed to"
}

variable "project" {
  description = "the project name"
}


variable "access_token" {
  description = "access token of the account"
}

data "template_file" "default" {
  template = file("${path.module}/startup.sh")
}

data "template_file" "startup_without_data" {
  template = file("${path.module}/startup_without_data.sh")
}

provider "google" {
  region = var.region
  zone = var.zone
  project = var.project
  access_token = var.access_token
}

resource "google_compute_instance" "ins1" {
    name = "ins1"
    machine_type = "e2-medium"
    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-11"
      }
    }

    network_interface {
        network = "default"

        access_config {
        
        }
    }

    metadata_startup_script = data.template_file.startup_without_data.rendered
}


resource "google_compute_instance" "ins2" {
    name = "ins2"
    machine_type = "e2-medium"
    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-11"
      }
    }

    network_interface {
        network = "default"

        access_config {
        
        }
    }
    attached_disk {
      source = google_compute_disk.disk1.self_link
      device_name = "ssd1"
    }

    metadata_startup_script = data.template_file.default.rendered
}

resource "google_compute_disk" "disk1" {
    name = "disk-1"
    size = 100
    type  = "pd-ssd"
}

