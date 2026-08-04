# Grants read-only access to secrets under secret/data/sample-app/*
# Apply with: vault policy write sample-app-policy sample-app-policy.hcl

path "secret/data/sample-app/*" {
  capabilities = ["read"]
}
