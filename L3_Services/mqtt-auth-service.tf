resource "kubernetes_service" "mqtt-auth-service" {
  metadata {
    name      = "mqtt-auth-service"
    namespace = "services"
  }
  spec {
    selector = {
      app = "mqtt-auth-service"
    }
    port {
      port        = 9090
      target_port = 9090
    }
  }
}

resource "kubernetes_deployment" "mqtt-auth-deployment" {
  metadata {
    name      = "mqtt-auth-service"
    namespace = "services"
    labels = {
      app = "mqtt-auth-service"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mqtt-auth-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "mqtt-auth-service"
        }
      }
      spec {
        container {
          image = "hengel2810/se09-mqtt-auth-service:f7ff437ffde58f31030d9903c0b332d984a6cd15"
          name  = "mqtt-auth-service"
          liveness_probe {
            http_get {
              path = "/health"
              port = 9090
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}
