terraform {
  required_version = "~>1.5.7"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.61.0"
    }
  }
}

resource "digitalocean_project" "this" {
  name        = "bhs-${var.environment}-doproj"
  description = "Belton Historical Society project for ${var.environment} environment"
  purpose     = "Web Application"
  environment = title(var.environment)

  resources = [
    digitalocean_droplet.bhs.urn,
  ]
}

resource "digitalocean_droplet" "bhs" {
  image  = "debian-12-x64"
  name   = "bhs-${var.environment}-rails-droplet"
  region = "nyc2"
  size   = "s-1vcpu-512mb-10gb"

  monitoring = true
  ipv6       = true
}
