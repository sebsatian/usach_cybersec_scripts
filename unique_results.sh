#!/bin/bash

# Script: unique_results.sh
# Función:
#   Consolida resultados de DNS, Nmap y Shodan para generar:
#   - all_unique_ips.txt
#   - all_unique_ports.txt
#
# Ejecución:
#   ./unique_results.sh
#
# Entradas (automáticas):
#   - ./subdomains/unique_ips_dns.txt
#   - ./shodan/unique_ips_shodan.txt
#   - ./shodan/unique_ports_shodan.txt
#   - ./nmap/results/final_results.csv
#
# Salidas:
#   - all_unique_ips.txt
#   - all_unique_ports.txt

set -e

# ======================
# Archivos de entrada
# ======================

DNS_IPS="./subdomains/unique_ips_dns.txt"
SHODAN_IPS="./shodan/unique_ips_shodan.txt"
SHODAN_PORTS="./shodan/unique_ports_shodan.txt"
NMAP_RESULTS="./nmap/results/final_results.csv"

# ======================
# Archivos de salida
# ======================

ALL_IPS="all_unique_ips.txt"
ALL_PORTS="all_unique_ports.txt"

echo "[+] Verificando archivos de entrada..."

check_file() {
  if [[ -f "$1" ]]; then
    echo "    [OK]   $1"
    return 0
  else
    echo "    [MISS] $1"
    return 1
  fi
}

FOUND_DNS_IPS=0
FOUND_SHODAN_IPS=0
FOUND_SHODAN_PORTS=0
FOUND_NMAP_RESULTS=0

check_file "$DNS_IPS" && FOUND_DNS_IPS=1
check_file "$SHODAN_IPS" && FOUND_SHODAN_IPS=1
check_file "$SHODAN_PORTS" && FOUND_SHODAN_PORTS=1
check_file "$NMAP_RESULTS" && FOUND_NMAP_RESULTS=1

echo

# ======================
# Consolidar IPs únicas
# ======================

echo "[+] Consolidando IPs únicas..."
> "$ALL_IPS"

[[ $FOUND_DNS_IPS -eq 1 ]] && cat "$DNS_IPS" >> "$ALL_IPS"
[[ $FOUND_SHODAN_IPS -eq 1 ]] && cat "$SHODAN_IPS" >> "$ALL_IPS"

if [[ $FOUND_NMAP_RESULTS -eq 1 ]]; then
  grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$NMAP_RESULTS" >> "$ALL_IPS"
fi

sort -u "$ALL_IPS" -o "$ALL_IPS"

TOTAL_IPS=$(wc -l < "$ALL_IPS")

echo "    [+] IPs únicas consolidadas: $TOTAL_IPS"
echo "    [+] Archivo generado: $ALL_IPS"
echo

# =========================
# Consolidar puertos únicos
# =========================

echo "[+] Consolidando puertos únicos..."
> "$ALL_PORTS"

[[ $FOUND_SHODAN_PORTS -eq 1 ]] && cat "$SHODAN_PORTS" >> "$ALL_PORTS"

if [[ $FOUND_NMAP_RESULTS -eq 1 ]]; then
  grep -Eo '\b[0-9]{1,5}\b' "$NMAP_RESULTS" \
    | awk '$1 >= 1 && $1 <= 65535' >> "$ALL_PORTS"
fi

sort -n -u "$ALL_PORTS" -o "$ALL_PORTS"

TOTAL_PORTS=$(wc -l < "$ALL_PORTS")

echo "    [+] Puertos únicos consolidados: $TOTAL_PORTS"
echo "    [+] Archivo generado: $ALL_PORTS"
echo

echo "[+] Consolidación finalizada correctamente."
