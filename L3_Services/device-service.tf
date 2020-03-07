//resource "kubernetes_service" "device-service" {
//  metadata {
//    name      = "device-service"
//    namespace = "services"
//  }
//  spec {
//    selector = {
//      app = "device-service"
//    }
//    port {
//      port        = 8090
//      target_port = 8090
//    }
//  }
//}
//
//resource "kubernetes_deployment" "device-deployment" {
//  metadata {
//    name      = "device-service"
//    namespace = "services"
//    labels = {
//      app = "device-service"
//    }
//  }
//  spec {
//    replicas = 2
//    selector {
//      match_labels = {
//        app = "device-service"
//      }
//    }
//    template {
//      metadata {
//        labels = {
//          app = "device-service"
//        }
//      }
//      spec {
//        container {
//          image = "hengel2810/se09-device-service:b88fe23c6dc64f42af2d961b7f7bf50a6f884d54"
//          name  = "device-service"
//          env {
//            name  = "POSTGRES_HOST"
//            value = "jdbc:postgresql://${data.digitalocean_database_cluster.postgres.host}}:${data.digitalocean_database_cluster.postgres.port}/${postgresql_database.device_service.name}?sslmode=require"
//          }
//          env {
//            name  = "POSTGRES_USER"
//            value = digitalocean_database_user.device_service.name
//          }
//          env {
//            name  = "POSTGRES_PASSWORD"
//            value = digitalocean_database_user.device_service.password
//          }
//          liveness_probe {
//            http_get {
//              path = "/"
//              port = 8090
//            }
//            initial_delay_seconds = 3
//            period_seconds        = 3
//          }
//        }
//      }
//    }
//  }
//}
