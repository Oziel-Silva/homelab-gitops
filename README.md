# Homelab GitOps Repository 🚀

Este repositório contém todas as configurações GitOps para o homelab, gerenciadas pelo ArgoCD.

## 📁 Estrutura

```
gitops/
├── argocd/                    # Configurações do ArgoCD
│   ├── values.yaml           # Valores Helm do ArgoCD
│   └── deploy.sh            # Script de deploy
├── applications/             # Definições de aplicações ArgoCD
├── monitoring/              # Stack de monitoramento
├── networking/              # Configurações de rede
└── README.md               # Este arquivo
```

## 🎯 Aplicações Gerenciadas

- **ArgoCD**: GitOps Controller
- **Monitoring Stack**: Prometheus, Grafana, etc.
- **Networking**: Ingress, DNS, etc.

## 🚀 Como usar

1. **ArgoCD**: Configure usando `argocd/deploy.sh`
2. **Aplicações**: Adicione manifests em suas respectivas pastas
3. **GitOps**: Push para o repositório e o ArgoCD sincroniza automaticamente

## 🔗 Links

- **ArgoCD UI**: https://argocd.127.0.0.1.sslip.io
- **Grafana**: https://grafana.127.0.0.1.sslip.io
- **Prometheus**: https://prometheus.127.0.0.1.sslip.io

---
**Powered by GitOps & ArgoCD** 🎊
