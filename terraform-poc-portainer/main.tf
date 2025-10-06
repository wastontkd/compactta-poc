provider "google" {
  project = "compactta-poc"
  region  = "us-east1"
}

terraform {
  backend "gcs" {
    bucket = "terraform-tfstate-poc"
  }
}


resource "google_compute_instance" "portainer" {
  name         = "compactta-poc-instance"
  machine_type = "e2-micro"
  zone         = "us-east1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
      labels = {
        my_label = "value"
      }
    }
  }

  tags = ["allow-portainer", "allow-dokuwiki", "http-server", "https-server"]

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

}

resource "google_compute_firewall" "regra_9443" {
  name    = "allow-portainer"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9443"]
  }

  # Definir source ranges (quem pode acessar)
  source_ranges = ["0.0.0.0/0"] # Qualquer IP (ajuste conforme necessidade)

  # Opcional: restringir por tags
  target_tags = ["allow-portainer"]

  description = "Libera porta 9443 para acesso externo"
}

resource "google_compute_firewall" "dokuwiki_8080" {
  name    = "allow-dokuwiki"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  # Definir source ranges (quem pode acessar)
  source_ranges = ["0.0.0.0/0"] # Qualquer IP (ajuste conforme necessidade)

  # Opcional: restringir por tags
  target_tags = ["allow-dokuwiki"]

  description = "Libera porta 8080 para acesso externo"
}

output "ip_publico" {
  description = "IP público da instância"
  value       = google_compute_instance.portainer.network_interface[0].access_config[0].nat_ip
}