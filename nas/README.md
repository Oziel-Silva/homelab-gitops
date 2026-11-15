# NAS (UGREEN DH2300 / UGOS Pro)

Monitoramento do NAS `DH2300-NAS` (`192.168.1.120`) no Prometheus e no Grafana do cluster.

```
nas/
├── README.md
└── exporters/
    ├── docker-compose.yml   # node-exporter + smartctl-exporter (rodam no NAS)
    └── check.sh             # confere se os exporters respondem e mostra as temperaturas
```

## Exporters

| Exporter | Porta | Métricas principais |
|----------|-------|---------------------|
| node-exporter | 9100 | `node_hwmon_temp_celsius` (CPU/placa), memória, rede, filesystem |
| smartctl-exporter | 9633 | `smartctl_device_temperature`, `smartctl_device_smart_status` (por disco) |

Sem autenticação: devem ficar acessíveis só na LAN.

## Instalação no NAS

1. No UGOS, habilite o app **Docker**.
2. Suba o projeto com `exporters/docker-compose.yml`. Pela interface do Docker do UGOS (Projeto/Compose) ou por SSH (porta 223), com `docker compose up -d` em `/home/oziel/nas-exporters`.
3. Da sua máquina, confira:
   ```bash
   ./exporters/check.sh            # ou ./exporters/check.sh <ip>
   ```

## Notas do deploy

- O NAS é `aarch64` (Debian 12, Docker 26.1): usar imagens arm64. O `smartctl-exporter` só tem arm64 a partir da v0.15.0.
- O `scp` padrão (SFTP) não enxerga `/home/oziel`; usar `scp -O -P 223`.
- Os sensores aparecem como `thermal_zone0..5` (sem nome de CPU/placa).

## Prometheus e Grafana

- `monitoring/homelab/nas-scrapeconfig.yaml`: `ScrapeConfig` para `192.168.1.120:9100` e `:9633` (label `host="dh2300-nas"`).
- `monitoring/homelab/homelab-dashboard.yaml`: dashboard `homelab` do Grafana (temperatura de discos e CPU, SMART, RAID, volume, CPU, memória, rede).
- Aplicados pela Application `homelab-monitoring`.

## Pendente

- Alertas de temperatura de disco/CPU e de falha SMART.
