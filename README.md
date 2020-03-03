# L1_CloudInfrastructure

- Create AWS User for CLI in the AWS console
- Create folder `.aws`
- Create file `credentials` in `.aws`:
```
[terraform]
aws_access_key_id = AWS_ACCESS_KEY_ID
aws_secret_access_key = AWS_SECRET_ACCESS_KEY
```
- Create file `terraform.tfvars` in root:
```
do_token = DIGITAL_OCEAN_API_TOKEN"
aws_region = "eu-central-1"
aws_zone = "eu-central-1a"

```


`terraform init`
`terraform plan`
`terraform apply`

https://learn.hashicorp.com/vault/day-one/ops-autounseal-aws-kms

SSH into AWS KMS  Vault
`ssh ubuntu@18.194.209.30 -i private.key`

`vault status`
`vault operator init -recovery-shares=1 -recovery-threshold=1`
`vault status`
`sudo systemctl restart vault`
`vault status`
`vault login XXX_ROOT_KEY`
`cat /etc/vault.d/vault.hcl`

# L2_InfrastructureConfig

`terraform init`
`terraform plan`
`terraform apply`

# L3_Services

`terraform init`
`terraform plan`
`terraform apply`

# Vault

Create SQL tables:

```
CREATE TABLE vault_kv_store (
  parent_path TEXT COLLATE "C" NOT NULL,
  path        TEXT COLLATE "C",
  key         TEXT COLLATE "C",
  value       BYTEA,
  CONSTRAINT pkey PRIMARY KEY (path, key)
);

CREATE INDEX parent_path_idx ON vault_kv_store (parent_path);
```

Init vault
`kse09 exec -ti -n vault vault-0 -- vault operator init`

Unseal vault (3 times)
`kse09 exec -ti -n vault vault-0 -- vault operator unseal`