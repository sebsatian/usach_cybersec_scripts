#!/bin/bash

# Script: comms.sh
# Ubicación: ./netcat/
#
# Función:
#   Valida conectividad real hacia servicios detectados por Nmap
#   utilizando Netcat (TCP), con timeout y captura de banners.
#
# Ejecución:
#   ./comms.sh -i ../nmap/nmap_focused.csv
#
# Entrada:
#   - CSV con columnas que incluyan al menos: ip,port,service
#
# Salida (en ./netcat/):
#   - connectivity_report.csv

set -e

INPUT_CSV=""
OUTPUT_CSV="connectivity_report.csv"
TIMEOUT=3

usage() {
  echo "Uso: $0 -i <nmap_focused.csv>"
  exit 1
}

# ======================
# Parseo de argumentos
# ======================

while getopts "i:" opt; do
  case $opt in
    i) INPUT_CSV="$OPTARG" ;;
    *) usage ;;
  esac
done

# ======================
# Validaciones
# ======================

if [[ -z "$INPUT_CSV" ]]; then
  echo "[ERROR] Debe especificar el archivo CSV de entrada."
  usage
fi

if [[ ! -f "$INPUT_CSV" ]]; then
  echo "[ERROR] No se encontró el archivo: $INPUT_CSV"
  exit 1
fi

command -v nc >/dev/null 2>&1 || {
  echo "[ERROR] Netcat (nc) no está instalado."
  exit 1
}

echo "[+] Iniciando validación de conectividad con Netcat"
echo "[+] Archivo de entrada: $INPUT_CSV"
echo "[+] Timeout por conexión: ${TIMEOUT}s"
echo

# ======================
# Inicializar salida
# ======================

echo "ip,port,service,connection_status,banner" > "$OUTPUT_CSV"

# ======================
# Procesamiento CSV
# ======================

# Detectar posiciones de columnas (header)
HEADER=$(head -n 1 "$INPUT_CSV")

IP_COL=$(echo "$HEADER" | tr ',' '\n' | nl -w1 | grep -i '^.*ip$' | awk '{print $1}')
PORT_COL=$(echo "$HEADER" | tr ',' '\n' | nl -w1 | grep -i '^.*port$' | awk '{print $1}')
SERVICE_COL=$(echo "$HEADER" | tr ',' '\n' | nl -w1 | grep -i '^.*service$' | awk '{print $1}')

if [[ -z "$IP_COL" || -z "$PORT_COL" || -z "$SERVICE_COL" ]]; then
  echo "[ERROR] El CSV debe contener columnas: ip, port, service"
  exit 1
fi

TOTAL_LINES=$(($(wc -l < "$INPUT_CSV") - 1))
CURRENT=0

# ======================
# Loop principal
# ======================

tail -n +2 "$INPUT_CSV" | while IFS=',' read -r -a ROW; do
  ip="${ROW[$((IP_COL-1))]}"
  port="${ROW[$((PORT_COL-1))]}"
  service="${ROW[$((SERVICE_COL-1))]}"

  CURRENT=$((CURRENT + 1))
  echo -ne "[+] Probando $ip:$port ($service) [$CURRENT/$TOTAL_LINES]\r"

  # Intento de conexión TCP y captura de banner
  BANNER=$(timeout "$TIMEOUT" nc -nv "$ip" "$port" 2>&1 | tr '\n' ' ' | sed 's/"/""/g')

  if echo "$BANNER" | grep -qiE "succeeded|open"; then
    STATUS="SUCCESS"
  else
    STATUS="FAILED"
  fi

  echo "\"$ip\",\"$port\",\"$service\",\"$STATUS\",\"$BANNER\"" >> "$OUTPUT_CSV"

done

echo
echo "[+] Validación de conectividad finalizada."
echo "[+] Reporte generado: ./netcat/$OUTPUT_CSV"
