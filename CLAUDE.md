# Homelab GitOps - Claude Code Instructions

## Project Overview

This is a GitOps repository for a homelab Kubernetes cluster managed by ArgoCD. All applications are deployed via the **App-of-Apps** pattern.

- **Repo**: `https://github.com/Oziel-Silva/homelab-gitops`
- **ArgoCD UI**: `https://argocd.127.0.0.1.sslip.io`
- **Ingress**: Gateway API (Envoy Gateway) with sslip.io wildcard domains

## Repository Structure

```
gitops/
├── Makefile             # bootstrap / delete / status do cluster
├── cluster/             # k3d-config.yaml (1 server + 2 agents) e README
├── applications/        # ArgoCD Application manifests (App-of-Apps)
├── argocd/              # ArgoCD Helm values e deploy.sh
├── networking/
│   ├── gateway-crds/    # CRDs do Gateway API (standard) + Envoy Gateway
│   ├── envoy-gateway/   # Controller Envoy Gateway
│   ├── cert-manager/    # cert-manager (certificados do Gateway)
│   └── gateway/         # GatewayClass, Gateway, Certificate, HTTPRoutes (manifests)
├── monitoring/          # Helm values: grafana, loki, prometheus, promtail, otel, tempo-distributed
└── internal-tools/
    └── backstage/
```

## Cluster

k3d sobre OrbStack (Mac Mini, headless). `make bootstrap` cria o cluster a partir de `cluster/k3d-config.yaml`
(Traefik embutido desabilitado; ingress via Gateway API) e roda `argocd/deploy.sh`, que instala o ArgoCD e aplica o App-of-Apps.
Dados usam `local-path` e são descartáveis (`make delete` apaga tudo). Acesso via `*.127.0.0.1.sslip.io`.

## Application Pattern

Every app follows the **multi-source** ArgoCD Application pattern:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: argocd
spec:
  project: default
  sources:
  - repoURL: <helm-chart-repo>
    chart: <chart-name>
    targetRevision: "<version>"
    helm:
      valueFiles:
      - $values/<path>/values.yaml
  - repoURL: https://github.com/Oziel-Silva/homelab-gitops
    targetRevision: HEAD
    ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: <namespace>
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```

Key points:
- Values files live in this repo, referenced via `$values` alias
- `targetRevision: "*"` means latest, pinned versions use semver (e.g., `"5.4.0"` or `"75.*.*"`)
- Automated sync with `prune: true` + `selfHeal: true` is opt-in per app

## Self-managed ArgoCD

`deploy.sh` instala o ArgoCD via Helm só no bootstrap. Depois disso ele é gerenciado pela Application `argocd` (`applications/argocd.yaml`):
mudanças em `argocd/values.yaml` ou na versão do chart são aplicadas por sync, **não** com `helm upgrade`. A Application não tem `resources-finalizer` nem sync automático.

## Namespaces

| Namespace    | Purpose                        |
|-------------|-------------------------------|
| `argocd`    | ArgoCD itself                 |
| `envoy-gateway-system` | Envoy Gateway, Gateway `homelab` e certificado |
| `cert-manager` | cert-manager               |
| `monitoring`| Prometheus, Grafana, Loki, Tempo, Promtail |
| `backstage` | Backstage (ver `applications/backstage.yaml`) |

## Deployed Applications

| App                   | Chart Repo                                 | Values Path                                    |
|----------------------|-------------------------------------------|-----------------------------------------------|
| argocd               | argoproj.github.io/argo-helm (v9.4.7)     | argocd/values.yaml                            |
| gateway-crds         | docker.io/envoyproxy (OCI, v1.9.2)        | networking/gateway-crds/values.yaml           |
| envoy-gateway        | docker.io/envoyproxy (OCI, v1.9.2)        | networking/envoy-gateway/values.yaml          |
| cert-manager         | charts.jetstack.io (v1.21.2)              | networking/cert-manager/values.yaml           |
| gateway              | este repo (diretório)                     | networking/gateway/*.yaml                     |
| grafana              | grafana.github.io/helm-charts             | monitoring/grafana/values.yaml                |
| kube-prometheus-stack | prometheus-community.github.io/helm-charts | monitoring/prometheus/values.yaml            |
| loki                 | grafana.github.io/helm-charts             | monitoring/loki/values.yaml                   |
| promtail             | grafana.github.io/helm-charts             | monitoring/promtail/values.yaml               |
| tempo                | grafana.github.io/helm-charts (tempo-distributed) | monitoring/tempo-distributed/values.yaml |
| backstage            | ver applications/backstage.yaml           | internal-tools/backstage/values.yaml          |

## Ingress (Gateway API)

- Sem Traefik/Ingress. Um único `Gateway` `homelab` (ns `envoy-gateway-system`) escuta 80/443 em `*.127.0.0.1.sslip.io`, com TLS self-signed via cert-manager.
- Cada app publica um `HTTPRoute` com `parentRefs: homelab`. Ex.: `networking/gateway/argocd-route.yaml`.
- Sync-waves: gateway-crds (-3) → envoy-gateway, cert-manager (-2) → gateway (-1).
- Os charts do Envoy Gateway são OCI: o repo está registrado em `argocd/values.yaml` (`configs.repositories`, `enableOCI`).
- Pendente: Prometheus, Loki e Backstage ainda têm blocos `ingress` com `ingressClassName: traefik` nos values; migrar para HTTPRoute.

## Key Conventions

- **Do not** use `automated.prune` unless explicitly required — data loss risk
- **Pin chart versions** for stateful apps (MinIO, databases) to avoid surprise upgrades
- Wildcard versions (`"*"` or `"75.*.*"`) are acceptable for observability tooling
- All Helm values go in `monitoring/<app>/values.yaml` or the relevant subfolder — never inline in the Application manifest
- The `app.kubernetes.io/name` label must match the `metadata.name` on every Application

## Workflow

Changes take effect by pushing to `main`. ArgoCD polls every 180s or can be manually synced via UI.

To add a new application:
1. Create `applications/<app-name>.yaml` following the multi-source pattern above
2. Create `<category>/<app-name>/values.yaml` with Helm overrides
3. Push to `main` — ArgoCD App-of-Apps will pick it up automatically

## Updating an app

1. All modifications to values.yaml should be committed and pushed to main.
2. ArgoCD application should be synced.