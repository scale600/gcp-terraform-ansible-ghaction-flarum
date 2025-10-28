# Terraform Outputs for GCP Flarum Deployment

output "vm_ip" {
  description = "VM external IP address"
  value       = google_compute_instance.flarum_vm.network_interface[0].access_config[0].nat_ip
}

output "db_host" {
  description = "Database host IP"
  value       = google_sql_database_instance.flarum_db.ip_address[0].ip_address
}

output "db_name" {
  description = "Database name"
  value       = google_sql_database.flarum.name
}

output "db_user" {
  description = "Database username"
  value       = google_sql_user.flarum_user.name
}

output "vm_internal_ip" {
  description = "VM internal IP address"
  value       = google_compute_instance.flarum_vm.network_interface[0].network_ip
}
