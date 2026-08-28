<img width="1912" height="907" alt="Screenshot 2026-08-28 230459" src="https://github.com/user-attachments/assets/c820da83-f351-4290-9aaa-700044130797" />
<img width="1918" height="922" alt="Screenshot 2026-08-28 225726" src="https://github.com/user-attachments/assets/cc49b26e-ca8c-4eae-bffc-994de0c0d147" />
<img width="1470" height="521" alt="Screenshot 2026-08-28 230211" src="https://github.com/user-attachments/assets/c76e016c-c02d-4c82-9b0e-5267e4057af9" />
# GitOps Deployment with ArgoCD & Vault

A GitOps pipeline on a local Kubernetes cluster (minikube) where **Git is
the single source of truth** for Kubernetes state: ArgoCD continuously
syncs the cluster to match this repo, and HashiCorp Vault injects secrets
into Pods at runtime instead of hardcoding them in manifests.

## Stack
- **Kubernetes (minikube)** — local single-node cluster
- **ArgoCD** — GitOps continuous delivery, automated sync + self-heal
- **HashiCorp Vault** — dynamic secret injection via the Agent Injector

## What this demonstrates
- Automated sync of Kubernetes manifests straight from a Git repo (no manual `kubectl apply` for app changes)
- Secrets managed and injected by Vault instead of committed to Git or stored in plain K8s Secrets
- Automated rollback/retry on failed deployments through ArgoCD's `syncPolicy` (`selfHeal`, `retry` with backoff, `argocd app rollback`)

## Repo layout
```
argocd/            ArgoCD Application manifest + install notes
vault/             Vault Helm values, K8s auth setup, ACL policy
apps/sample-app/   The app ArgoCD deploys (Deployment, Service, Kustomization)
docs/              Architecture diagram/notes
```

## Setup order
1. `minikube start --cpus=4 --memory=8192` — spin up the local cluster
2. Follow `argocd/install-notes.md` — install ArgoCD, apply `argocd/application.yaml`
3. Install Vault: `helm install vault hashicorp/vault -n vault --create-namespace -f vault/vault-values.yaml`
4. Follow `vault/setup.md` — enable K8s auth, write the policy, seed the secret
5. Push a change under `apps/sample-app/` and watch ArgoCD sync it automatically

See `docs/architecture.md` for the full flow diagram.

## Scope notes
This is a portfolio/demo setup on a local minikube cluster, built and
documented as part of hands-on DevOps practice (Cairo, 2026). Vault runs in
**dev mode** here for simplicity — `vault/vault-values.yaml` documents what
changes for a production deployment (Raft/Consul storage backend, real
unsealing, no static root token, and a managed cluster like EKS instead of
minikube).
"# GitOps-Deployment-with-ArgoCD-Vault" 
