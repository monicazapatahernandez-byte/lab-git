#!/usr/bin/env bash
set -euo pipefail


DIR="${1:-.}"
LOGIN=${USER:-alumno27}

# Extraer número del login (27 en tu caso)
NUM=$(echo "$LOGIN" | sed -E 's/.*[^0-9]*([0-9]+)$/\1/')

# Si falla, usar 2 como división por defecto
if ! [[ "$NUM" =~ ^[0-9]+$ ]] || [ "$NUM" -le 0 ]; then
  NUM=2
fi

mkdir -p "$DIR/cut"
shopt -s nullglob

for fq in "$DIR"/*.fastq "$DIR"/*.fastq.gz; do
    [ -e "$fq" ] || continue

    base=$(basename "$fq")
    out="$DIR/cut/$base"

    echo "Procesando $fq -> $out (manteniendo 1/$NUM aprox.)"

    if [[ "$fq" == *.gz ]]; then
        total_lines=$(gzip -dc "$fq" | wc -l)
        total_reads=$(( total_lines / 4 ))
        keep_reads=$(( (total_reads + NUM - 1) / NUM ))
        keep_lines=$(( keep_reads * 4 ))
        gzip -dc "$fq" | head -n "$keep_lines" | gzip > "$out"
    else
        total_lines=$(wc -l < "$fq")
        total_reads=$(( total_lines / 4 ))
        keep_reads=$(( (total_reads + NUM - 1) / NUM ))
        keep_lines=$(( keep_reads * 4 ))
        head -n "$keep_lines" "$fq" > "$out"
    fi

    echo "Guardado $out (antes: $total_reads lecturas, ahora: $keep_reads)"
done

