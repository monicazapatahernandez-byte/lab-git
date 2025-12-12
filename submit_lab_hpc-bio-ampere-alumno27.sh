#!/bin/bash
#SBATCH --job-name=lab3-cut-alumno27
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
#SBATCH --partition=hpc-bio-ampere
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G

set -euo pipefail

# Directorio del repositorio
cd "$HOME/ampere/lab-git" || exit 1

TARGET_DIR="data"

# Detectar ficheros FASTQ
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

echo "Procesando $n ficheros en paralelo con srun..."

# Lanzar un srun por fichero (un proceso exclusivo por archivo)
for fq in "${real_files[@]}"; do
    echo "SLURM -> procesando $fq"
    srun --exclusive -N1 -n1 -c1 bash -lc "./file-cut.sh '$fq'" &
done

wait

echo "Trabajo SLURM completado correctamente."

