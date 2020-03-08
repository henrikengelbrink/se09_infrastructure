resource "kubernetes_service" "vault_link" {
  metadata {
    name      = "vault-link"
    namespace = "services"
  }
  spec {
    type          = "ExternalName"
    external_name = "vault.vault.svc.cluster.local"
    port {
      port = 8200
    }
  }
}

resource "kubernetes_service" "link_vernemq_auth" {
  metadata {
    name      = "link-vernemq-auth"
    namespace = "mqtt"
  }
  spec {
    type          = "ExternalName"
    external_name = "mqtt-auth-service.services.svc.cluster.local"
    port {
      port = 9090
    }
  }
}
