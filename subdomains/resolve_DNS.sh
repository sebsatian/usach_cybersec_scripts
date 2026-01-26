#!/bin/bash

# Script: resolve_DNS.sh
# Función:
#   Resuelve cada subdominio usando dig y genera:
#   1) Un CSV con todas las resoluciones DNS (CNAME y A):
#        domain,ip_or_domain
#   2) Un archivo con IPs IPv4 numéricas únicas:
#        unique_ips_dns.txt
#
# Entrada:
#   - Archivo TXT con subdominios (uno por línea)
#
# Salidas:
#   - domain_ip.csv
#   - unique_ips_dns.txt

set -e

INPUT_FILE=""
OUTPUT_CSV="domain_ip.csv"
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

echo "[+] Resolviendo subdominios DNS ($TOTAL_DOMAINS dominios)"

# Inicializar salidas
echo "domain,ip_or_domain" > "$OUTPUT_CSV"
> "$UNIQUE_IPS_FILE"

# Resolución DNS con progreso
while IFS= read -r domain; do
  domain=$(echo "$domain" | tr -d '\r' | xargs)
  [[ -z "$domain" ]] && continue

  CURRENT=$((CURRENT + 1))
  echo -ne "[+] Progreso: $CURRENT/$TOTAL_DOMAINS\r"

  results=$(dig +short "$domain")

  for result in $results; do
    echo "$domain,$result" >> "$OUTPUT_CSV"

    # Guardar solo IPs IPv4 numéricas en unique_ips_dns.txt
    if [[ "$result" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      echo "$result" >> "$UNIQUE_IPS_FILE"
    fi
  done

done < "$INPUT_FILE"

# Deduplicar IPs numéricas
sort -u "$UNIQUE_IPS_FILE" -o "$UNIQUE_IPS_FILE"

TOTAL_IPS=$(wc -l < "$UNIQUE_IPS_FILE")
TOTAL_ROWS=$(($(wc -l < "$OUTPUT_CSV") - 1))

echo
echo "[+] Resolución DNS finalizada."
echo "[+] Archivo generado: $OUTPUT_CSV"
echo "[+] Filas domain→resultado generadas: $TOTAL_ROWS"
echo "[+] IPs IPv4 únicas detectadas: $TOTAL_IPS"
