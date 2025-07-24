# Homelab GitOps Repository 🚀

This repository contains all GitOps configurations for the homelab, managed by ArgoCD.

## 📁 Structure

```
gitops/
├── argocd/                    # ArgoCD configurations
│   ├── values.yaml           # ArgoCD Helm values
│   └── deploy.sh            # Deployment script
├── applications/             # ArgoCD application definitions
├── monitoring/              # Monitoring stack
├── networking/              # Network configurations
└── README.md               # This file
```

## 🎯 Managed Applications

- **ArgoCD**: GitOps Controller
- **Monitoring Stack**: Prometheus, Grafana, etc.
- **Networking**: Ingress, DNS, etc.

## 🚀 How to use

1. **ArgoCD**: Configure using `argocd/deploy.sh`
2. **Applications**: Add manifests to their respective folders
3. **GitOps**: Push to repository and ArgoCD syncs automatically

## 🔗 Links

- **ArgoCD UI**: https://argocd.127.0.0.1.sslip.io
- **Grafana**: https://grafana.127.0.0.1.sslip.io
- **Prometheus**: https://prometheus.127.0.0.1.sslip.io

---
