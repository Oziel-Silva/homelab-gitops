# Homelab GitOps - Claude Code Instructions

## Project Overview

This is a GitOps repository for a homelab Kubernetes cluster managed by ArgoCD. All applications are deployed via the **App-of-Apps** pattern.

- **Repo**: `https://github.com/Oziel-Silva/homelab-gitops`
- **ArgoCD UI**: `https://argocd.127.0.0.1.sslip.io`
- **Ingress**: Traefik with sslip.io wildcard domains

## Repository Structure

```
gitops/
├── applications/        # ArgoCD Application manifests (App-of-Apps)
├── argocd/              # ArgoCD Helm values and deploy script
├── monitoring/          # Helm values per monitoring app
│   ├── grafana/
│   ├── loki/
│   ├── prometheus/
│   ├── promtail/
│   ├── tempo/
│   └── tempo-distributed/
├── networking/          # Network configs (Traefik, etc.)
│   └── backstage/
└── internal-tools/      # Internal tooling
```

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

## Namespaces

| Namespace    | Purpose                        |
|-------------|-------------------------------|
| `argocd`    | ArgoCD itself                 |
| `monitoring`| Prometheus, Grafana, Loki, Tempo, Promtail |
| `data`      | MinIO                         |

## Deployed Applications

| App                  | Chart Repo                              | Values Path                        |
|---------------------|----------------------------------------|------------------------------------|
| grafana             | grafana.github.io/helm-charts          | monitoring/grafana/values.yaml     |
| kube-prometheus-stack | prometheus-community.github.io/helm-charts | monitoring/prometheus/values.yaml |
| loki                | grafana.github.io/helm-charts          | monitoring/loki/values.yaml        |
| promtail            | grafana.github.io/helm-charts          | monitoring/promtail/values.yaml    |
| tempo               | grafana.github.io/helm-charts          | monitoring/tempo/values.yaml       |
| minio               | charts.min.io/ (pinned 5.4.0)         | data-project/minio/values.yaml     |
| hive-ms             | custom                                 | -                                  |
| trino               | custom                                 | -                                  |

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