#!/bin/bash

# Inicializa variables
ENTRADA_JSON=""
CSV_SALIDA="masscan_ip_ports.csv"
IPS_UNICAS="uniq_ips_masscan.txt"
PUERTOS_UNICOS="uniq_ports_masscan.txt"

# Función de ayuda
function uso() {
    echo "Uso: $0 -i archivo.json"
    exit 1
}

# Parseo de argumentos
while getopts ":i:" opt; do
    case ${opt} in
        i )
            ENTRADA_JSON="$OPTARG"
            ;;
        \? )
            echo "Opción inválida: -$OPTARG" >&2
            uso
            ;;
        : )
            echo "Opción -$OPTARG requiere un argumento." >&2
            uso
            ;;
    esac
done

# Validar entrada
if [[ -z "$ENTRADA_JSON" ]]; then
    echo "Error: debes especificar un archivo de entrada con -i"
    uso
fi

if [[ ! -f "$ENTRADA_JSON" ]]; then
    echo "Error: archivo '$ENTRADA_JSON' no encontrado."
    exit 1
fi

# Verifica que jq esté instalado
if ! command -v jq &> /dev/null; then
    echo "Error: jq no está instalado. Instálalo con: sudo apt install jq"
    exit 1
fi

# Procesar el JSON
echo "ip,port" > "$CSV_SALIDA"
jq -r '.[] | [.ip, .ports[]?.port] | @csv' "$ENTRADA_JSON" | tr -d '"' >> "$CSV_SALIDA"

# IPs únicas
cut -d',' -f1 "$CSV_SALIDA" | tail -n +2 | sort -u > "$IPS_UNICAS"

# Puertos únicos
cut -d',' -f2 "$CSV_SALIDA" | tail -n +2 | sort -nu > "$PUERTOS_UNICOS"

echo "Listo:"
echo "- CSV: $CSV_SALIDA"
echo "- IPs únicas: $IPS_UNICAS"
echo "- Puertos únicos: $PUERTOS_UNICOS"
