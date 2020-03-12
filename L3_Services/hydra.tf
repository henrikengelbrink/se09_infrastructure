data "helm_repository" "ory" {
  name = "ory"
  url  = "https://k8s.ory.sh/helm/charts"
}

resource "helm_release" "hydra" {
  name = "hydra"
  repository = data.helm_repository.ory.metadata.0.name
  chart = "ory/hydra"
  namespace = "auth"
  set {
    name = "hydra.config.secrets.system"
    value = "H874MrzXJQzesPNmSpVHnCCaYMZYjXtl"
  }
  set {
    name = "hydra.config.dsn"
    value = "memory"
  }
  set {
    name = "hydra.config.urls.self.issuer"
    value = "https://hydra.engelbrink.dev"
  }
  set {
    name = "hydra.config.urls.login"
    value = "https://user.engelbrink.dev/auth/login"
  }
  set {
    name = "hydra.config.urls.consent"
    value = "https://user.engelbrink.dev/auth/consent"
  }
  set {
    name = "hydra.dangerousForceHttp"
    value = "true"
  }
}

//resource "kubernetes_pod" "hydra_client_setup" {
//  metadata {
//    name = "hydra-client-setup"
//    namespace = "auth"
//  }
//  spec {
//    restart_policy                  = "Never"
//    container {
//      image = "oryd/hydra"
//      name  = "hydra-client-setup"
//      #command = ["ls", "-la"]
//      command = ["clients", "create", "--endpoint", "http://hydra-admin:4445", "--id", "test-client", "--secret", "test-secret", "--response-types", "code,id_token", "--grant-types", "refresh_token,authorization_code", "--scope openid,offline", "--callbacks", "com.example-app:/oauth2/callback"]
//      #command = "sleep 30 && clients create --endpoint http://hydra-admin:4445 --id test-client --secret test-secret --response-types code,id_token --grant-types refresh_token,authorization_code --scope openid,offline --callbacks com.example-app:/oauth2/callback"
//    }
//  }
//  depends_on = [
//    helm_release.hydra
//  ]
//}

