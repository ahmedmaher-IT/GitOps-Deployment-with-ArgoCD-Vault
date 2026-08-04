# Installing ArgoCD on the minikube Cluster

1. Create the namespace and install the core manifests:

   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. Wait for all ArgoCD pods to become `Running`:

   ```bash
   kubectl get pods -n argocd -w
   ```

3. Get the initial admin password and log in with the CLI:

   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret \
     -o jsonpath="{.data.password}" | base64 -d

   kubectl port-forward svc/argocd-server -n argocd 8080:443
   argocd login localhost:8080 --username admin
   ```

4. Register this repo and apply the Application:

   ```bash
   argocd repo add https://github.com/ahmedmaher-IT/gitops-argocd-vault-eks.git
   kubectl apply -f argocd/application.yaml
   ```

From this point on, any commit to `apps/sample-app` in Git is automatically
synced to the cluster (`automated.selfHeal` + `automated.prune`) — this is
the actual GitOps loop: Git is the single source of truth, not `kubectl apply`.
