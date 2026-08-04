# Architecture

```
Git repo (source of truth)
   │  push
   ▼
GitHub ── polled/webhooked by ──▶ ArgoCD (in-cluster)
                                       │  automated sync (selfHeal + prune)
                                       ▼
                          Kubernetes (minikube) — sample-app namespace
                                       │
                                       ▼ (Vault Agent Injector sidecar)
                                  HashiCorp Vault
                                  (KV secrets engine, k8s auth)
```

**Flow:**
1. A change to `apps/sample-app/*` is pushed to GitHub.
2. ArgoCD detects the diff between Git and the live cluster state and syncs
   automatically (`syncPolicy.automated`).
3. If a synced revision fails health checks, ArgoCD's `retry` policy retries
   with backoff; `argocd app rollback` reverts to the last healthy Git
   revision if needed.
4. When a Pod starts, the Vault Agent Injector mutates it to add a sidecar
   that authenticates to Vault via the Kubernetes auth method and writes
   secrets to a local, non-persisted file — nothing sensitive lives in Git
   or in a plain Kubernetes Secret.

**Why GitOps here:** the cluster's desired state is fully described by this
repo. `kubectl apply` is only used once, to install ArgoCD itself — after
that, every change to the app goes through Git, giving an audit trail and a
one-command rollback path.
