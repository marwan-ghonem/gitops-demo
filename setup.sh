#!/bin/bash

# GitOps Demo Quick Setup Script
# This script helps you set up the project quickly

set -e

echo "🚀 GitOps Demo - Quick Setup"
echo "================================"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

echo "✅ kubectl found"

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USER
read -p "Enter your repo name (default: gitops-demo): " REPO_NAME
REPO_NAME=${REPO_NAME:-gitops-demo}

echo ""
echo "Configuration:"
echo "  GitHub User: $GITHUB_USER"
echo "  Repo Name: $REPO_NAME"
echo ""

# Update ArgoCD application
echo "📝 Updating ArgoCD application.yaml..."
sed -i.bak "s|YOUR_USERNAME|$GITHUB_USER|g" argocd/application.yaml
sed -i.bak "s|YOUR_REPO|$REPO_NAME|g" argocd/application.yaml

# Update deployment
echo "📝 Updating deployment.yaml..."
sed -i.bak "s|YOUR_USERNAME|$GITHUB_USER|g" k8s/deployment.yaml
sed -i.bak "s|YOUR_REPO|$REPO_NAME|g" k8s/deployment.yaml

# Clean up backup files
rm -f argocd/application.yaml.bak k8s/deployment.yaml.bak

echo ""
echo "✅ Configuration updated!"
echo ""
echo "Next steps:"
echo "1. Create GitHub repo: https://github.com/new"
echo "2. Initialize git:"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial commit'"
echo "   git branch -M main"
echo "   git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo "   git push -u origin main"
echo ""
echo "3. Check if ArgoCD is installed:"
echo "   kubectl get namespace argocd"
echo ""
echo "4. If not installed, run:"
echo "   ./install-argocd.sh"
echo ""
echo "5. Deploy the application:"
echo "   kubectl apply -f argocd/application.yaml"
echo ""
echo "📚 See README.md for detailed instructions"
echo ""
