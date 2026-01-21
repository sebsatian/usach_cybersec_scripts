#!/bin/bash

# ======================
# Configuración inicial
# ======================
BASE_IP="158.170"
RESULTS_DIR="./results"
TXT_DIR="$RESULTS_DIR/txt"
XML_DIR="$RESULTS_DIR/xml"
CSV_FILE="$RESULTS_DIR/final_results.csv"

# ======================
# Crear carpetas
# ======================
mkdir -p "$TXT_DIR" "$XML_DIR"

# ======================
# Inicializar CSV
# ======================
echo "Subred,IP,Puerto,Estado,Servicio" > "$CSV_FILE"

# ======================
# Iterar por todas las subredes 0–255
# ======================
for SUBNET in {0..255}; do
    NET="${BASE_IP}.${SUBNET}.0/24"
    OUTPUT_PREFIX="scan_${BASE_IP}_${SUBNET}"

    echo "[*] Escaneando $NET..."

    nmap -sV -p- -T4 -n --open "$NET" \
         -oN "$TXT_DIR/${OUTPUT_PREFIX}.txt" \
         -oX "$XML_DIR/${OUTPUT_PREFIX}.xml"

    echo "[+] Escaneo de $NET completado. Procesando resultados..."

    # ================================
    # Extraer datos clave del .txt a CSV
    # ================================
    awk -v subnet="${BASE_IP}.${SUBNET}" '
    /^Nmap scan report for/ { ip=$NF }
    /^[0-9]+\/tcp/ {
        split($1, port_proto, "/")
        port=port_proto[1]
        estado=$2
        servicio=$3
        printf("%s,%s,%s,%s,%s\n", subnet, ip, port, estado, servicio)
    }' "$TXT_DIR/${OUTPUT_PREFIX}.txt" >> "$CSV_FILE"
done

echo "Todos los escaneos completados. CSV final disponible en: $CSV_FILE"
