resource "helm_release" "oathkeeper" {
  name = "oathkeeper"
  repository = data.helm_repository.ory.metadata.0.name
  chart = "ory/oathkeeper"
  version = "v0.0.48"
  namespace = "auth"
  timeout = 60
  values = [<<EOF
oathkeeper:
  config:
    access_rules:
      repositories:
        - inline://${filebase64("${path.module}/oathkeeper-rules.json")}
    authenticators:
      noop:
        enabled: true
    authorizers:
      allow:
        enabled: true
    mutators:
      noop:
        enabled: true
EOF
  ]
}
