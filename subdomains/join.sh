#!/bin/bash

# Script: join_all_subdomains.sh
# Función:
#   Consolida los archivos de subdominios encontrados (usach.txt,
#   udesantiago.txt, segic.txt) en un único archivo eliminando duplicados.
#
# Salida:
#   all_subdomains.txt

set -e

OUTPUT_FILE="all_subdomains.txt"

INPUT_FILES=(
  "usach.txt"
  "udesantiago.txt"
  "segic.txt"
)

# Verificación de archivos de entrada
for file in "${INPUT_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "[ERROR] No se encontró el archivo requerido: $file"
    exit 1
  fi
done

echo "[+] Consolidando subdominios..."

# Concatenar, limpiar espacios, eliminar líneas vacías y duplicados
cat "${INPUT_FILES[@]}" \
  | sed 's/\r//g' \
  | sed '/^\s*$/d' \
  | sort -u \
  > "$OUTPUT_FILE"

COUNT=$(wc -l < "$OUTPUT_FILE")

echo "[+] Proceso completado."
echo "[+] Archivo generado: $OUTPUT_FILE"
echo "[+] Total de subdominios únicos: $COUNT"
