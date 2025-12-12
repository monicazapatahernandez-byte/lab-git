#!/bin/bash
#SBATCH --job-name=lab3-cut-alumno27
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
#SBATCH --ntasks=4
#SBATCH --time=01:00:00
#SBATCH --mem=4G

# Ir al directorio del repositorio
cd "$HOME/ampere/lab-git" || exit 1

TARGET_DIR="data"

# Comprobar que existen fastq
files=( "$TARGET_DIR"/*.fastq "$TARGET_DIR"/*.fastq.gz )
real_files=()
for f in "${files[@]}"; do
    [ -e "$f" ] && real_files+=("$f")
done

n=${#real_files[@]}
if [ "$n" -eq 0 ]; then
    echo "No se encontraron archivos FASTQ en $TARGET_DIR"
    exit 0
fi

# Calcular reparto en 4 tareas
chunk=$(( (n + 3) / 4 ))

for i in 0 1 2 3; do
    start=$(( i * chunk ))
    (
        for j in $(seq $start $((start + chunk - 1))); do
            [ $j -lt $n ] || break
            ./file-cut.sh "${real_files[$j]}"
        done
    ) &
done

wait

echo "Trabajo SLURM completado."

