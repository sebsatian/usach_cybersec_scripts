#!/bin/bash

# Script: focused_scan.sh
# Ubicación: ./nmap/
#
# Función:
#   Ejecuta un escaneo Nmap focalizado usando únicamente
#   IPs y puertos previamente identificados como activos.
#
# Entradas (desde la carpeta raíz del repo):
#   - ../all_unique_ips.txt
#   - ../all_unique_ports.txt
#
# Salida:
#   - nmap_focused.xml
#
# Ejecución recomendada (tmux):
#   ./focused_scan.sh

set -e

# ======================
# Archivos de entrada
# ======================

IPS_FILE="../all_unique_ips.txt"
PORTS_FILE="../all_unique_ports.txt"

# ======================
# Archivo de salida
# ======================

OUTPUT_XML="nmap_focused.xml"

echo "[+] Iniciando escaneo Nmap focalizado"

# ======================
# Verificación de inputs
# ======================

check_file() {
  if [[ -f "$1" ]]; then
    echo "    [OK]   $1"
  else
    echo "    [ERROR] Archivo requerido no encontrado: $1"
    exit 1
  fi
}

check_file "$IPS_FILE"
check_file "$PORTS_FILE"

echo

# ======================
# Construcción de puertos
# ======================

PORTS=$(tr '\n' ',' < "$PORTS_FILE" | sed 's/,$//')

if [[ -z "$PORTS" ]]; then
  echo "[ERROR] La lista de puertos está vacía."
  exit 1
fi

TOTAL_IPS=$(wc -l < "$IPS_FILE")
TOTAL_PORTS=$(wc -l < "$PORTS_FILE")

echo "[+] IPs a escanear: $TOTAL_IPS"
echo "[+] Puertos a escanear: $TOTAL_PORTS"
echo

# ======================
# Ejecución de Nmap
# ======================

echo "[+] Ejecutando Nmap..."
echo "[+] Comando:"
echo "    nmap -Pn -sV -sC -iL $IPS_FILE -p $PORTS -oX $OUTPUT_XML"
echo

nmap -Pn -sV -sC \
  -iL "$IPS_FILE" \
  -p "$PORTS" \
  -oX "$OUTPUT_XML"

echo
echo "[+] Escaneo focalizado finalizado."
echo "[+] Resultado generado: $OUTPUT_XML"
