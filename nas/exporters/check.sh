#!/bin/bash
# Verifica se os exporters do NAS respondem e mostra as temperaturas.
# Uso: ./check.sh [IP_DO_NAS]   (padrão: 192.168.1.120)

NAS="${1:-192.168.1.120}"

echo "== node-exporter (http://${NAS}:9100) - sensores hwmon"
curl -s -m 5 "http://${NAS}:9100/metrics" | grep -E '^node_hwmon_temp_celsius' \
  || echo "sem node_hwmon_temp_celsius (exporter fora do ar ou sem acesso aos sensores)"

echo
echo "== smartctl-exporter (http://${NAS}:9633) - temperatura dos discos"
curl -s -m 10 "http://${NAS}:9633/metrics" | grep -E '^smartctl_device_temperature' \
  || echo "sem smartctl_device_temperature (exporter fora do ar ou sem acesso aos discos)"
