resource "kubernetes_service" "hibp_service" {
  metadata {
    name      = "hibp-service"
    namespace = "default"
  }
  spec {
    selector = {
      app = "hibp-service"
    }
    port {
      port        = 8282
      target_port = 8282
    }
  }
}

resource "kubernetes_deployment" "hibp_deployment" {
  metadata {
    name      = "hibp-service"
    namespace = "default"
    labels = {
      app = "hibp-service"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "hibp-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "hibp-service"
        }
      }
      spec {
        service_account_name            = "device-service"
        automount_service_account_token = "true"
        container {
          image = "hengel2810/se09-hibp:0.18"
          name  = "device-service"
        }
      }
    }
  }
}
