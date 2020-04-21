resource "kubernetes_network_policy" "allow_vault" {
  metadata {
    name      = "allow-vault"
    namespace = "default"
  }
  spec {
    pod_selector {
      match_labels = {
        app.kubernetes.io/name = "vault"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      ports {
        port     = "8200"
        protocol = "TCP"
      }
      from {
        pod_selector {
          match_labels = {
            app = "cert-service"
          }
        }
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_hydra" {
  metadata {
    name      = "allow-hydra"
    namespace = "default"
  }
  spec {
    pod_selector {
      match_labels = {
        app.kubernetes.io/name = "hydra"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      ports {
        port     = "4444"
        protocol = "TCP"
      }
      ports {
        port     = "4445"
        protocol = "TCP"
      }
      from {
        pod_selector {
          match_labels {
            app = "hydra-init"
          }
        }
      }
      from {
        pod_selector {
          match_labels = {
            app.kubernetes.io/name = "oathkeeper"
          }
        }
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_oathkeeper" {
  metadata {
    name      = "allow-oathkeeper"
    namespace = "default"
  }
  spec {
    pod_selector {
      match_labels = {
        app.kubernetes.io/name = "oathkeeper"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      ports {
        port     = "4455"
        protocol = "TCP"
      }
      from {
        pod_selector {
          match_labels = {
            app.kubernetes.io/name = "ambassador"
          }
        }
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_user_service" {
  metadata {
    name      = "allow-user-service"
    namespace = "default"
  }
  spec {
    pod_selector {
      match_labels {
        app      = "user-service"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      ports {
        port     = "8585"
        protocol = "TCP"
      }
      from {
        pod_selector {
          match_labels = {
            app = "cert-service"
          }
        }
      }
      from {
        pod_selector {
          match_labels = {
            app = "device-service"
          }
        }
      }
      from {
        pod_selector {
          match_labels = {
            app.kubernetes.io/name = "oathkeeper"
          }
        }
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_device_service" {
  metadata {
    name      = "allow-device-service"
    namespace = "default"
  }
  spec {
    pod_selector {
      match_labels {
        app      = "device-service"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      ports {
        port     = "7979"
        protocol = "TCP"
      }
      from {
        pod_selector {
          match_labels = {
            app = "cert-service"
          }
        }
      }
      from {
        pod_selector {
          match_labels = {
            app.kubernetes.io/name = "oathkeeper"
          }
        }
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_cert_service" {
  metadata {
    name      = "allow-cert-service"
    namespace = "default"
  }
  spec {
    pod_selector {
      match_labels {
        app      = "cert-service"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      ports {
        port     = "7878"
        protocol = "TCP"
      }
      from {
        pod_selector {
          match_labels = {
            app = "device-service"
          }
        }
      }
      from {
        pod_selector {
          match_labels = {
            app.kubernetes.io/name = "vernemq"
          }
        }
      }
    }
  }
}
