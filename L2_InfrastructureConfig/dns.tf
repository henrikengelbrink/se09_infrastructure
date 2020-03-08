data "kubernetes_service" "load_balancer" {
  metadata {
    name      = "voyager-main-ingress"
    namespace = "voyager"
  }
  depends_on = [
    null_resource.load_balancer_delay
  ]
}

resource "digitalocean_domain" "dns_cluster_domain" {
  name       = var.cluster_domain
  ip_address = data.kubernetes_service.load_balancer.load_balancer_ingress.0.ip
  depends_on = [
    null_resource.load_balancer_delay
  ]
}

resource "digitalocean_record" "cluster_domain_sub_example" {
  domain = digitalocean_domain.dns_cluster_domain.name
  type   = "A"
  name   = "example"
  value  = data.kubernetes_service.load_balancer.load_balancer_ingress.0.ip
  depends_on = [
    digitalocean_domain.dns_cluster_domain
  ]
}

resource "digitalocean_record" "cluster_domain_sub_mqtt" {
  domain = digitalocean_domain.dns_cluster_domain.name
  type   = "A"
  name   = "mqtt"
  value  = data.kubernetes_service.load_balancer.load_balancer_ingress.0.ip
  depends_on = [
    digitalocean_domain.dns_cluster_domain
  ]
}
