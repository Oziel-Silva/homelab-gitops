#!/bin/bash

# ArgoCD Helm Deploy - Zero to Hero
# Simple deployment using Helm Chart

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🚀 ArgoCD Helm Deployment${NC}"
echo ""

# Add ArgoCD Helm repository
echo -e "${BLUE}Adding ArgoCD Helm repository...${NC}"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace
echo -e "${BLUE}Creating argocd namespace...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Deploy ArgoCD
echo -e "${BLUE}Deploying ArgoCD with Helm...${NC}"
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values values.yaml \
  --wait \
  --timeout 10m

echo ""
echo -e "${GREEN}✅ ArgoCD deployed successfully!${NC}"
echo ""
echo -e "${BLUE}Access URL:${NC} http://argocd.127.0.0.1.sslip.io"
echo ""
echo -e "${BLUE}Get admin password:${NC}"
echo "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
