resource "helm_release" "oathkeeper" {
  name = "oathkeeper"
  repository = data.helm_repository.ory.metadata.0.name
  chart = "ory/oathkeeper"
  version = "v0.0.48"
  namespace = "auth"
  timeout = 60
  values = [<<EOF
image:
  repository: oryd/oathkeeper
  tag: v0.36.0-beta.4
  pullPolicy: IfNotPresent
oathkeeper:
  config:
    log:
      level: debug
      format: text
    access_rules:
      repositories:
        - inline://${filebase64("${path.module}/oathkeeper-rules.json")}
    authenticators:
      noop:
        enabled: true
      oauth2_introspection:
        enabled: true
        config:
          introspection_url: http://hydra-admin:4445/oauth2/introspect
          scope_strategy: exact
          required_scope:
            - openid
            - offline
    authorizers:
      allow:
        enabled: true
    mutators:
      noop:
        enabled: true
      hydrator:
        enabled: true
        config:
          api:
            url: http://user-service:8585/auth/hydrator
            retry:
              give_up_after: 6s
              max_delay: 2s
EOF
  ]
}
