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

resource "kubernetes_service" "link_vernemq_device_service" {
  metadata {
    name      = "link-vernemq-device-service"
    namespace = "mqtt"
  }
  spec {
    type          = "ExternalName"
    external_name = "device-service.services.svc.cluster.local"
    port {
      port = 7979
    }
  }
}

resource "kubernetes_service" "link_device_service_auth" {
  metadata {
    name      = "link-device-service-auth"
    namespace = "auth"
  }
  spec {
    type          = "ExternalName"
    external_name = "device-service.services.svc.cluster.local"
    port {
      port = 7979
    }
  }
}

resource "kubernetes_service" "device_auth_link" {
  metadata {
    name      = "device-auth-link"
    namespace = "services"
  }
  spec {
    type          = "ExternalName"
    external_name = "user-service.auth.svc.cluster.local"
    port {
      port = 8585
    }
  }
}