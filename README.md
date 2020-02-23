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