#!/bin/bash

# ArgoCD Installation Script for Dev Cluster

set -e

echo "🔧 Installing ArgoCD"
echo "==================="
echo ""

# Check if ArgoCD namespace exists
if kubectl get namespace argocd &> /dev/null; then
    echo "ℹ️  ArgoCD namespace already exists"
    read -p "Do you want to reinstall? (y/N): " REINSTALL
    if [[ $REINSTALL != "y" && $REINSTALL != "Y" ]]; then
        echo "Skipping installation"
        exit 0
    fi
    kubectl delete namespace argocd
fi

# Create namespace
echo "📦 Creating argocd namespace..."
kubectl create namespace argocd

# Install ArgoCD
echo "📥 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready (this may take a few minutes)..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo ""
echo "✅ ArgoCD installed successfully!"
echo ""

# Get initial admin password
echo "🔑 Getting ArgoCD admin password..."
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "================================"
echo "ArgoCD Access Information"
echo "================================"
echo ""
echo "Username: admin"
echo "Password: $PASSWORD"
echo ""
echo "To access ArgoCD UI:"
echo "1. Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Open: https://localhost:8080"
echo "3. Accept the self-signed certificate"
echo "4. Login with credentials above"
echo ""
echo "⚠️  Save this password! The secret will be deleted after first login."
echo ""
echo "To change password:"
echo "argocd account update-password"
echo ""
