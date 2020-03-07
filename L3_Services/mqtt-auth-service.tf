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
    replicas = 2
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
          image = "hengel2810/se09-mqtt-auth-service:9a8e4d7568c7c235b14447ec54a3efa3bfe98b65"
          name  = "mqtt-auth-service"
          liveness_probe {
            http_get {
              path = "/"
              port = 9090
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
