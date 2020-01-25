resource "kubernetes_service" "terraform-example-app-service" {
  metadata {
    name = "terraform-example-app"
    namespace = "http"
  }
  spec {
    selector = {
      app = "terraform-example-app"
    }
    port {
      port = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "terraform-example-app-deployment" {
  metadata {
    name = "terraform-example-app"
    namespace = "http"
    labels = {
      app = "terraform-example-app"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "terraform-example-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "terraform-example-app"
        }
      }
      spec {
        container {
          image = "tutum/hello-world:latest"
          name = "terraform-example-app"
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds = 3
          }
        }
      }
    }
  }
}