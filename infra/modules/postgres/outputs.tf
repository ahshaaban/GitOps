# ── PostgreSQL Module Outputs ─────────────────────────────────────────────────

output "server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.pg.id
}

output "server_name" {
  description = "Name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.pg.name
}

output "server_fqdn" {
  description = "Fully qualified domain name of the server."
  value       = azurerm_postgresql_flexible_server.pg.fqdn
}

output "admin_login" {
  description = "Administrator login name."
  value       = azurerm_postgresql_flexible_server.pg.administrator_login
}
