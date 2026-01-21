#!/usr/bin/env bash
# filter_shodan.sh
# Uso: ./filter_shodan.sh -i shodan.csv
# Salidas: ips.txt  ports.txt

set -euo pipefail

# Valores por defecto
INPUT_FILE=""
IPS_OUT="uniq_ips_shodan.txt"
PORTS_OUT="uniq_ports_shodan.txt"
TMP_CLEAN="$(mktemp)"

# Función de ayuda
uso() {
  echo "Uso: $0 -i archivo.csv"
  exit 1
}

# Parsear flags
while getopts ":i:" opt; do
  case ${opt} in
    i)
      INPUT_FILE="$OPTARG"
      ;;
    \?)
      echo "Opción inválida: -$OPTARG" >&2
      uso
      ;;
    :)
      echo "La opción -$OPTARG requiere un argumento." >&2
      uso
      ;;
  esac
done

# Validación del archivo
if [[ -z "$INPUT_FILE" ]]; then
  echo "Error: debes especificar un archivo CSV con -i"
  uso
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: archivo '$INPUT_FILE' no encontrado."
  exit 1
fi

# 1) Normalizar
sed 's/,$//' "$INPUT_FILE" | awk 'NF{gsub(/[[:space:]]+/,","); print}' > "$TMP_CLEAN"

# 2) IPs únicas
awk -F',' '{print $1}' "$TMP_CLEAN" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u > "$IPS_OUT"

# 3) Puertos únicos
awk -F',' '{print $2}' "$TMP_CLEAN" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | grep -E '^[0-9]+$' | sort -n -u > "$PORTS_OUT"

# 4) Informe
echo "Archivos generados:"
echo " - $IPS_OUT ( $(wc -l < "$IPS_OUT" | tr -d ' ') IPs únicas )"
echo " - $PORTS_OUT ( $(wc -l < "$PORTS_OUT" | tr -d ' ') puertos únicos )"
