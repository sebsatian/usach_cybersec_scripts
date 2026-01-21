
echo "Iniciando descarga..."
shodan search --fields ip_str,port "net:158.170.0.0/16" --limit 1000 > shodan.csv
echo "Descarga finalizada. Archivo resultante: 'shodan.csv'"
