data "helm_repository" "helm_repo_vernemq" {
  name = "vernemq"
  url  = "https://vernemq.github.io/docker-vernemq"
}

resource "helm_release" "vernemq_cluster" {
  name       = "vernemq-cluster"
  repository = data.helm_repository.helm_repo_vernemq.metadata.0.name
  chart      = "vernemq/vernemq"
  namespace  = "mqtt"
  set {
    name  = "replicaCount"
    value = 1
  }
  set {
    name  = "image.tag"
    value = "1.10.1"
  }
  set {
    name  = "service.mqtts.enabled"
    value = "true"
  }
  values = [<<EOF
additionalEnv:
    - name: DOCKER_VERNEMQ_ACCEPT_EULA
      value: "yes"
    - name: DOCKER_VERNEMQ_PLUGINS__VMQ_ACL
      value: "off"
    - name: DOCKER_VERNEMQ_PLUGINS__VMQ_WEBHOOKS
      value: "on"
    - name: DOCKER_VERNEMQ_PLUGINS__VMQ_PASSWD
      value: "off"
    - name: DOCKER_VERNEMQ_LISTENER__SSL__CAFILE
      value: "/vault/secrets/chain.crt"
    - name: DOCKER_VERNEMQ_LISTENER__SSL__CERTFILE
      value: "/vault/secrets/server.crt"
    - name: DOCKER_VERNEMQ_LISTENER__SSL__KEYFILE
      value: "/vault/secrets/server.key"
    - name: DOCKER_VERNEMQ_LISTENER__SSL__DEFAULT
      value: "0.0.0.0:8883"
    - name: DOCKER_VERNEMQ_VMQ_WEBHOOKS__auth_on_register__hook
      value: "auth_on_register"
    - name: DOCKER_VERNEMQ_VMQ_WEBHOOKS__auth_on_register__endpoint
      value: "http://mqtt-auth-service.services.svc.cluster.local:9090/vernemq/auth_on_register"
    - name: DOCKER_VERNEMQ_VMQ_WEBHOOKS__auth_on_subscribe__hook
      value: "auth_on_subscribe"
    - name: DOCKER_VERNEMQ_VMQ_WEBHOOKS__auth_on_subscribe__endpoint
      value: "http://mqtt-auth-service.services.svc.cluster.local:9090/vernemq/auth_on_subscribe"
    - name: DOCKER_VERNEMQ_VMQ_WEBHOOKS__auth_on_publish__hook
      value: "auth_on_publish"
    - name: DOCKER_VERNEMQ_VMQ_WEBHOOKS__auth_on_publish__endpoint
      value: "http://mqtt-auth-service.services.svc.cluster.local:9090/vernemq/auth_on_publish"
statefulset:
  podAnnotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "vernemq-role"
    vault.hashicorp.com/agent-inject-secret-chain.crt: "secret/mqtt-server-chain"
    vault.hashicorp.com/agent-inject-template-chain.crt: |
      {{- with secret "secret/mqtt-server-chain" -}}
      {{ .Data.data.chain_crt }}
      {{- end }}
    vault.hashicorp.com/agent-inject-secret-server.crt: "secret/mqtt-server-cert"
    vault.hashicorp.com/agent-inject-template-server.crt: |
      {{- with secret "secret/mqtt-server-cert" -}}
      {{ .Data.data.server_crt }}
      {{- end }}
    vault.hashicorp.com/agent-inject-secret-server.key: "secret/mqtt-server-key"
    vault.hashicorp.com/agent-inject-template-server.key: |
      {{- with secret "secret/mqtt-server-key" -}}
      {{ .Data.data.server_key }}
      {{- end }}
EOF
  ]
}

resource "kubernetes_service" "mqtt_broker_service_http_debug" {
  metadata {
    name      = "vernemq-dashboard"
    namespace = "mqtt"
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "vernemq-cluster"
      "app.kubernetes.io/name"     = "vernemq"
    }
    port {
      port        = 8888
      target_port = 8888
    }
  }
  depends_on = [
    helm_release.vernemq_cluster
  ]
}
