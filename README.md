# GitOps Demo Project 🚀

## Overview

This project demonstrates a complete GitOps workflow using:
- **GitHub Actions** (CI - Build & Push)
- **ArgoCD** (CD - Deploy to Kubernetes)
- **GKE** (Your dev cluster)

## Architecture

```
Code Push → GitHub Actions → Docker Build → GHCR Push → Update Manifest
              ↓
            Git Commit
              ↓
          ArgoCD Watches Git → Syncs to K8s → App Deployed ✅
```

## Prerequisites

- Access to AppOut GKE dev cluster
- `kubectl` configured for your cluster
- GitHub account
- ArgoCD installed on your cluster (or we'll install it)

---

## Setup Instructions

### Step 1: Create GitHub Repository

```bash
# Create a new repo on GitHub (e.g., gitops-demo)
# Then clone it locally
git clone https://github.com/YOUR_USERNAME/gitops-demo.git
cd gitops-demo

# Copy all project files into this directory
```

### Step 2: Update Configuration

**Update these files with your information:**

1. **argocd/application.yaml**
   ```yaml
   repoURL: https://github.com/YOUR_USERNAME/gitops-demo.git
   ```

2. **k8s/deployment.yaml**
   ```yaml
   image: ghcr.io/YOUR_USERNAME/gitops-demo/gitops-demo:latest
   ```

3. **.github/workflows/ci-cd.yml**
   - No changes needed! It uses variables automatically

### Step 3: Install ArgoCD (if not already installed)

```bash
# Check if ArgoCD is already installed
kubectl get namespace argocd

# If not installed, run:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port-forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at: https://localhost:8080
# Username: admin
# Password: (from command above)
```

### Step 4: Push Code to GitHub

```bash
# Initialize git (if new repo)
git init
git add .
git commit -m "Initial commit: GitOps demo project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/gitops-demo.git
git push -u origin main
```

### Step 5: Deploy ArgoCD Application

```bash
# Apply the ArgoCD Application
kubectl apply -f argocd/application.yaml

# Check status
kubectl get application -n argocd

# Watch the sync
kubectl get application gitops-demo -n argocd -w
```

### Step 6: Verify Deployment

```bash
# Check if pods are running
kubectl get pods -n dev

# Check the service
kubectl get svc -n dev

# Port-forward to test the app
kubectl port-forward svc/gitops-demo -n dev 3000:80

# Test in browser or curl
curl http://localhost:3000
curl http://localhost:3000/health
curl http://localhost:3000/info
```

---

## Testing the GitOps Flow

### Test 1: Make a Code Change

1. **Edit app.js**:
   ```javascript
   message: 'Hello from GitOps Demo v2.0! 🎉',
   ```

2. **Commit and push**:
   ```bash
   git add app.js
   git commit -m "Update welcome message"
   git push
   ```

3. **Watch the magic**:
   ```bash
   # GitHub Actions will:
   # 1. Build new Docker image
   # 2. Push to GHCR
   # 3. Update k8s/deployment.yaml
   # 4. Commit the change
   
   # ArgoCD will:
   # 1. Detect the change
   # 2. Sync to cluster
   # 3. Rolling update pods
   
   # Watch it happen
   kubectl get pods -n dev -w
   ```

### Test 2: Manual Change Detection (Self-Heal)

```bash
# Manually scale up (breaks GitOps)
kubectl scale deployment gitops-demo -n dev --replicas=5

# ArgoCD will detect drift and revert back to 2 replicas!
# Check ArgoCD UI - you'll see "OutOfSync" then "Synced"
```

### Test 3: Rollback

```bash
# In ArgoCD UI:
# 1. Click on your application
# 2. Click "History"
# 3. Click "Rollback" on previous version

# Or via Git:
git revert HEAD
git push

# ArgoCD will deploy the previous version!
```

---

## ArgoCD UI Tour

Access: `https://localhost:8080` (after port-forward)

**What you'll see:**

1. **Application Card**
   - Name: gitops-demo
   - Status: Synced/OutOfSync
   - Health: Healthy/Degraded

2. **Application Details**
   - Visual graph of all resources
   - Deployment → ReplicaSet → Pods
   - Service pointing to Pods

3. **Sync Status**
   - Last sync time
   - Commit hash
   - Sync result

4. **History**
   - All deployments
   - One-click rollback

---

## Troubleshooting

### GitHub Actions failing?

```bash
# Check workflow permissions
# GitHub repo → Settings → Actions → General → Workflow permissions
# Enable: "Read and write permissions"
```

### ArgoCD not syncing?

```bash
# Check application status
kubectl describe application gitops-demo -n argocd

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-application-controller

# Manual sync
kubectl patch application gitops-demo -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'
```

### Pods not starting?

```bash
# Check pod logs
kubectl logs -n dev deployment/gitops-demo

# Check events
kubectl get events -n dev --sort-by='.lastTimestamp'

# Check image pull
kubectl describe pod -n dev $(kubectl get pods -n dev -o name | head -1)
```

---

## Project Structure

```
gitops-demo/
├── app.js                      # Node.js application
├── package.json                # Dependencies
├── Dockerfile                  # Container image
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions CI/CD
├── k8s/
│   ├── namespace.yaml         # Kubernetes namespace
│   ├── deployment.yaml        # Kubernetes deployment
│   └── service.yaml           # Kubernetes service
├── argocd/
│   └── application.yaml       # ArgoCD Application
└── README.md                  # This file
```

---

## What You Learned

✅ **GitHub Actions**: Build, test, push Docker images
✅ **Docker**: Multi-stage builds, best practices
✅ **Kubernetes**: Deployments, Services, health checks
✅ **ArgoCD**: GitOps, automatic sync, self-healing
✅ **GitOps**: Git as single source of truth
✅ **CI/CD**: Complete automated pipeline

---

## Next Steps

1. **Add Tests**: Add actual tests in GitHub Actions
2. **Add Ingress**: Expose app externally
3. **Add Monitoring**: Prometheus metrics endpoint
4. **Add Multiple Environments**: dev, staging, prod
5. **Add Helm**: Convert to Helm chart
6. **Add Secrets**: Use Sealed Secrets or External Secrets

---

## Useful Commands

```bash
# View all resources in dev namespace
kubectl get all -n dev

# Watch pods
kubectl get pods -n dev -w

# View logs
kubectl logs -n dev -l app=gitops-demo -f

# Port-forward app
kubectl port-forward svc/gitops-demo -n dev 3000:80

# Port-forward ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Delete everything
kubectl delete application gitops-demo -n argocd
kubectl delete namespace dev
```

---

## Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitOps Principles](https://opengitops.dev/)

---

**Happy GitOps! 🚀**

Created by: Marwan - DevOps Team
```

