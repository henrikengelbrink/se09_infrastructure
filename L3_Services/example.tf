resource "kubernetes_service" "example-app-service" {
  metadata {
    name      = "example-app"
    namespace = "default"
  }
  spec {
    selector = {
      app = "example-app"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "example-app-deployment" {
  metadata {
    name      = "example-app"
    namespace = "default"
    labels = {
      app = "example-app"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "example-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "example-app"
        }
      }
      spec {
        container {
          image = "tutum/hello-world:latest"
          name  = "example-app"
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
