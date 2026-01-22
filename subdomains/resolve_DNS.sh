#!/bin/bash

# Script: resolve_DNS.sh
# Función:
#   Resuelve direcciones IP asociadas a una lista de subdominios
#   utilizando consultas DNS (dig).
#
# Entrada:
#   - Archivo TXT con subdominios (uno por línea)
#
# Salidas:
#   - subdomains_with_ips.csv
#   - unique_ips_dns.txt

set -e

INPUT_FILE=""
OUTPUT_CSV="subdomains_with_ips.csv"
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

echo "[+] Resolviendo subdominios desde: $INPUT_FILE"

# Cabecera CSV
echo "subdomain,ip" > "$OUTPUT_CSV"

# Procesamiento
while IFS= read -r domain; do
  # Limpieza básica
  domain=$(echo "$domain" | tr -d '\r' | xargs)

  [[ -z "$domain" ]] && continue

  # Resolución DNS (A records)
  ips=$(dig +short A "$domain")

  for ip in $ips; do
    echo "$domain,$ip" >> "$OUTPUT_CSV"
    echo "$ip" >> "$UNIQUE_IPS_FILE"
  done

done < "$INPUT_FILE"

# Limpieza y deduplicación de IPs
sort -u "$UNIQUE_IPS_FILE" -o "$UNIQUE_IPS_FILE"

TOTAL_DOMAINS=$(wc -l < "$INPUT_FILE")
TOTAL_IPS=$(wc -l < "$UNIQUE_IPS_FILE")

echo "[+] Resolución DNS finalizada."
echo "[+] Archivo generado: $OUTPUT_CSV"
echo "[+] IPs únicas detectadas: $TOTAL_IPS"
echo "[+] Subdominios procesados: $TOTAL_DOMAINS"
