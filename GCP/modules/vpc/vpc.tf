#-------------------------------------------------------------------------------
# Defines Custom VPC
#-------------------------------------------------------------------------------
resource "google_compute_network" "vpc-a3" {
  name                    = "vpc-a3"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

#-------------------------------------------------------------------------------
# Defines Public and Private Subnets for custom VPC
#-------------------------------------------------------------------------------
resource "google_compute_subnetwork" "public-subnet" {
  name                     = "public-subnet"
  ip_cidr_range            = "172.16.0.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc-a3.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private-subnet" {
  name                     = "private-subnet"
  ip_cidr_range            = "172.16.100.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc-a3.self_link
  private_ip_google_access = true
}
