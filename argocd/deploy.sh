#!/bin/bash

# ArgoCD Helm Deploy
# Simple deployment using Helm Chart

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Pinned versions
# Versão do chart lida de applications/argocd.yaml (fonte única; depois do bootstrap o ArgoCD se autogerencia)
CHART_VERSION=$(awk '/chart: argo-cd/{f=1} f && /targetRevision/{gsub(/"/,"",$2); print $2; exit}' ../applications/argocd.yaml)
ARGOCD_APP_VERSION="v3.3.2"

echo -e "${GREEN}🚀 ArgoCD Helm Deployment${NC}"
echo -e "${BLUE}Chart version:${NC} ${CHART_VERSION} (ArgoCD ${ARGOCD_APP_VERSION})"
echo ""

# Add ArgoCD Helm repository
echo -e "${BLUE}Adding ArgoCD Helm repository...${NC}"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Check if a newer chart version is available
LATEST_VERSION=$(helm search repo argo/argo-cd --output json | jq -r '.[0].version')
if [ "${LATEST_VERSION}" != "${CHART_VERSION}" ]; then
  echo -e "${YELLOW}⚠️  Newer chart available: ${LATEST_VERSION} (pinned to ${CHART_VERSION})${NC}"
  echo -e "${YELLOW}   Update CHART_VERSION in this script when ready to upgrade.${NC}"
else
  echo -e "${GREEN}✅ Chart version ${CHART_VERSION} is up to date.${NC}"
fi
echo ""

# Check currently deployed version (if any)
if helm status argocd -n argocd &>/dev/null; then
  DEPLOYED_VERSION=$(helm list -n argocd -o json | jq -r '.[] | select(.name=="argocd") | .chart' | sed 's/argo-cd-//')
  echo -e "${BLUE}Currently deployed chart version:${NC} ${DEPLOYED_VERSION}"
  if [ "${DEPLOYED_VERSION}" = "${CHART_VERSION}" ]; then
    echo -e "${YELLOW}Already on ${CHART_VERSION}, performing upgrade/sync...${NC}"
  fi
  echo ""
fi

# Create namespace
echo -e "${BLUE}Creating argocd namespace...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Deploy ArgoCD
echo -e "${BLUE}Deploying ArgoCD with Helm...${NC}"
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version "${CHART_VERSION}" \
  --values values.yaml \
  --wait \
  --timeout 10m

echo ""
echo -e "${GREEN}✅ ArgoCD deployed successfully!${NC}"
echo ""

# Apply App-of-Apps
echo -e "${BLUE}Applying App-of-Apps...${NC}"
kubectl apply -f ../applications/app-of-apps.yaml

echo ""
echo -e "${GREEN}✅ App-of-Apps applied!${NC}"
echo ""
echo -e "${BLUE}Access URL:${NC} http://argocd.127.0.0.1.sslip.io"
echo ""
echo -e "${BLUE}Get admin password:${NC}"
echo "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
