# Vault Setup: Kubernetes Auth + Secret Injection

These steps wire Vault into the cluster so the app's Pods get secrets
injected at runtime instead of reading them from hardcoded env vars or
Kubernetes Secrets committed to Git.

## 1. Enable the KV secrets engine and add a secret

```bash
kubectl exec -n vault vault-0 -- vault secrets enable -path=secret kv-v2

kubectl exec -n vault vault-0 -- vault kv put secret/sample-app/config \
  db_password="super-secret-value" \
  api_key="demo-api-key"
```

## 2. Enable Kubernetes auth so Vault can verify pod identities

```bash
kubectl exec -n vault vault-0 -- vault auth enable kubernetes

kubectl exec -n vault vault-0 -- vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc:443"
```

## 3. Write the policy and bind it to the app's service account

```bash
kubectl cp policies/sample-app-policy.hcl vault/vault-0:/tmp/sample-app-policy.hcl -n vault
kubectl exec -n vault vault-0 -- vault policy write sample-app-policy /tmp/sample-app-policy.hcl

kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/sample-app \
  bound_service_account_names=sample-app-sa \
  bound_service_account_namespaces=sample-app \
  policies=sample-app-policy \
  ttl=1h
```

## 4. How injection happens

The app's Pod template (`apps/sample-app/deployment.yaml`) carries
Vault Agent Injector annotations. When a Pod with the `sample-app-sa`
service account starts, the injector adds a sidecar that authenticates
to Vault, fetches `secret/data/sample-app/config`, and writes it to
`/vault/secrets/config` inside the container — no secret ever sits in
a Kubernetes Secret object or the Git repo.
