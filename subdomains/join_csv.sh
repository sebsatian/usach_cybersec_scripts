#!/bin/bash

# Uso:
# ./joincsv.sh -i file1.csv,file2.csv,file3.csv -o final.csv

# Parseo de argumentos
while getopts "i:o:" opt; do
  case $opt in
    i) input_files="$OPTARG";;
    o) output_file="$OPTARG";;
    *) echo "Uso: $0 -i file1.csv,file2.csv -o final.csv"; exit 1;;
  esac
done

# Validaciones
if [[ -z "$input_files" || -z "$output_file" ]]; then
  echo "Faltan argumentos. Uso: $0 -i file1.csv,file2.csv -o final.csv"
  exit 1
fi

# Convertir lista separada por comas en array
IFS=',' read -r -a files <<< "$input_files"

# Unir archivos
first=1
> "$output_file"
for f in "${files[@]}"; do
  if [[ $first -eq 1 ]]; then
    cat "$f" >> "$output_file"
    first=0
  else
    tail -n +2 "$f" >> "$output_file"
  fi
done

echo "CSVs combinados en $output_file"
