#!/bin/bash
#SBATCH -A hpc2n2025-261
#SBATCH -t 12:00:00
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --mem=32G
#SBATCH -J NanoPlot_array
#SBATCH --array=0-7
#SBATCH -o logs/nanoplot_%A_%a.out
#SBATCH -e logs/nanoplot_%A_%a.err

export BREEDMAPS="/pfs/proj/nobackup/fs/projnb10/hpc2nstor2025-071"

# Les 7 échantillons
SAMPLE_IDS=(033 034 035 036 037 038 039 040)
ID=${SAMPLE_IDS[$SLURM_ARRAY_TASK_ID]}
SAMPLE_DIR=$BREEDMAPS/louis/data/Hifi.Batch02.pr_219/pr_219_${ID}

# Trouver automatiquement le fichier BAM dans le dossier
BAM=$(ls ${SAMPLE_DIR}/*.bam | head -1)
OUTDIR=$BREEDMAPS/louis/results/nanoplot/pr_219_${ID}
mkdir -p ${OUTDIR}

echo "=== pr_219_${ID} === BAM: $(basename $BAM) === $(date) ==="

module load GCC/12.3.0 OpenMPI/4.1.5 NanoPlot/1.43.0

NanoPlot --threads $SLURM_CPUS_PER_TASK \
         --ubam ${BAM} \
         -o ${OUTDIR}

echo "Fin: $(date)"
