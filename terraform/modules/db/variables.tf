variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable zone {
  description = "zone of VM dislocaton"
  default     = "europe-east1-a"
}
