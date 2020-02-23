output "LoadBalancer_IP" {
  value = data.kubernetes_service.load_balancer.load_balancer_ingress.0.ip
}
output "vault_pg_pw" {
  value = digitalocean_database_user.vault.password
}
