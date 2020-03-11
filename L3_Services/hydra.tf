//resource "kubernetes_service" "hydra" {
//  metadata {
//    name      = "hydra"
//    namespace = "auth"
//  }
//  spec {
//    selector = {
//      app = "hydra"
//    }
//    port {
//      port        = 4444
//      target_port = 4444
//    }
//  }
//}
//
//resource "kubernetes_deployment" "hydra" {
//  metadata {
//    name      = "hydra"
//    namespace = "auth"
//    labels = {
//      app = "hydra"
//    }
//  }
//  spec {
//    replicas = 1
//    selector {
//      match_labels = {
//        app = "hydra"
//      }
//    }
//    template {
//      metadata {
//        labels = {
//          app = "hydra"
//        }
//      }
//      spec {
//        container {
//          image = "oryd/hydra:v1.3.2-alpine"
//          name  = "hydra"
//          command = ["serve", "all", "--dangerous-force-http"]
//          env {
//            name  = "OAUTH2_SHARE_ERROR_DEBUG"
//            value = 1
//          }
//          env {
//            name  = "LOG_LEVEL"
//            value = "debug"
//          }
//          env {
//            name  = "OAUTH2_CONSENT_URL"
//            value = "http://user-service:8585/auth/consent"
//          }
//          env {
//            name  = "OAUTH2_LOGIN_URL"
//            value = "http://user-service:8585/auth/login"
//          }
//          env {
//            name  = "OAUTH2_ISSUER_URL"
//            value = "http://hydra:4444"
//          }
//          env {
//            name  = "DATABASE_URL"
//            value = "memory"
//          }
//          liveness_probe {
//            http_get {
//              path = "/health/ready"
//              port = 4445
//            }
//            initial_delay_seconds = 30
//            period_seconds        = 30
//          }
//        }
//      }
//    }
//  }
//}
//
////resource "kubernetes_pod" "hydra_client_setup" {
////  metadata {
////    name = "hydra-client-setup"
////    namespace = "auth"
////  }
////  spec {
////    restart_policy                  = "Never"
////    container {
////      image = "oryd/hydra:v1.3.2-alpine"
////      name  = "hydra-client-setup"
////      command = ["sleep", "30", "&&", "clients", "create", "--endpoint", "http://hydra:4445", "--id", "test-client", "--secret", "test-secret", "--response-types", "code,id_token", "--grant-types", "refresh_token,authorization_code", "--scope openid,offline", "--callbacks", "com.example-app:/oauth2/callback"]
////      #command = "sleep 30 && clients create --endpoint http://hydra:4445 --id test-client --secret test-secret --response-types code,id_token --grant-types refresh_token,authorization_code --scope openid,offline --callbacks com.example-app:/oauth2/callback"
////    }
////  }
////  depends_on = [
////    kubernetes_deployment.hydra
////  ]
////}
