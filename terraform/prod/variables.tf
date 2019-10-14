variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-rubyapp"
}
variable project {
  description = "Project ID"
  default     = "infra-253210"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable private_key_path {
  description = "Path to the private key for SSH for user appuser"
}
variable zone {
  description = "zone of VM dislocaton2"
  default     = "europe-west1-d"
}

