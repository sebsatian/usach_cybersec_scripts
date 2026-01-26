#!/bin/bash

# Script: resolve_DNS.sh
# Función:
#   Resuelve subdominios a IPs y genera un CSV con el formato:
#   IP, dominio1, dominio2, dominio3, ...
#   Soporta múltiples dominios por IP y columnas dinámicas.
#
# Entrada:
#   - Archivo TXT con subdominios (uno por línea)
#
# Salidas:
#   - ip_domains.csv
#   - unique_ips_dns.txt

set -e

INPUT_FILE=""
OUTPUT_CSV="ip_domains.csv"
UNIQUE_IPS_FILE="unique_ips_dns.txt"

usage() {
  echo "Uso: $0 -i <archivo_subdominios.txt>"
  exit 1
}

# Parseo de argumentos
while getopts "i:" opt; do
  case $opt in
    i) INPUT_FILE="$OPTARG" ;;
    *) usage ;;
  esac
done

# Validaciones
if [[ -z "$INPUT_FILE" ]]; then
  echo "[ERROR] Debe especificar un archivo de entrada."
  usage
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "[ERROR] No se encontró el archivo: $INPUT_FILE"
  exit 1
fi

TOTAL_DOMAINS=$(grep -cv '^\s*$' "$INPUT_FILE")
CURRENT=0

declare -A IP_DOMAINS
declare -A DOMAIN_SEEN

echo "[+] Resolviendo subdominios DNS ($TOTAL_DOMAINS dominios)"

# Resolución DNS con progreso
while IFS= read -r domain; do
  domain=$(echo "$domain" | tr -d '\r' | xargs)
  [[ -z "$domain" ]] && continue

  CURRENT=$((CURRENT + 1))
  echo -ne "[+] Progreso: $CURRENT/$TOTAL_DOMAINS\r"

  ips=$(dig +short A "$domain")

  for ip in $ips; do
    # Evitar duplicar el mismo dominio para una IP
    key="${ip}|${domain}"
    if [[ -z "${DOMAIN_SEEN[$key]}" ]]; then
      IP_DOMAINS["$ip"]+="${domain} "
      DOMAIN_SEEN["$key"]=1
      echo "$ip" >> "$UNIQUE_IPS_FILE"
    fi
  done

done < "$INPUT_FILE"

echo
echo "[+] Resolución DNS finalizada. Procesando resultados..."

# Deduplicar IPs
sort -u "$UNIQUE_IPS_FILE" -o "$UNIQUE_IPS_FILE"

# Determinar máximo de dominios por IP (para el header)
MAX_DOMAINS=0
for ip in "${!IP_DOMAINS[@]}"; do
  COUNT=$(echo "${IP_DOMAINS[$ip]}" | wc -w)
  (( COUNT > MAX_DOMAINS )) && MAX_DOMAINS=$COUNT
done

# Construir header dinámico
HEADER="ip"
for ((i=1; i<=MAX_DOMAINS; i++)); do
  HEADER+=",domain_$i"
done
echo "$HEADER" > "$OUTPUT_CSV"

# Construir filas
for ip in "${!IP_DOMAINS[@]}"; do
  ROW="$ip"
  for domain in ${IP_DOMAINS[$ip]}; do
    ROW+=",$domain"
  done
  echo "$ROW" >> "$OUTPUT_CSV"
done

TOTAL_IPS=$(wc -l < "$UNIQUE_IPS_FILE")

echo "[+] Archivo generado: $OUTPUT_CSV"
echo "[+] IPs únicas detectadas: $TOTAL_IPS"
echo "[+] Máximo de dominios asociados a una IP: $MAX_DOMAINS"
