#!/bin/bash
#SBATCH -A hpc2n2025-261
#SBATCH -J QC_pbmm2_2.0
#SBATCH -t 02:00:00
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --mem=32G
#SBATCH --array=0-7
#SBATCH -o logs/qc_2.0_%A_%a.out
#SBATCH -e logs/qc_2.0_%A_%a.err
#SBATCH --mail-user=louis.deglin@slu.se
#SBATCH --mail-type=ALL

echo "Début du job QC : $(date)"

module load GCC/14.2.0 SAMtools/1.22

export BREEDMAPS="/pfs/proj/nobackup/fs/projnb10/hpc2nstor2025-071"
export container="/home/l/louis/container"

SAMPLE_IDS=(033 034 035 036 037 038 039 040)
ID=${SAMPLE_IDS[$SLURM_ARRAY_TASK_ID]}

TARGET_DIR=$BREEDMAPS/louis/results/pbmm2/ARS-UCD2.0/pr_219_${ID}

BAM=$(ls ${TARGET_DIR}/Aligned_*.bam | head -1)
BAM_NAME=$(basename $BAM)

echo "=== QC pour pr_219_${ID} (Réf 2.0) == BAM: ${BAM_NAME} ==="

#Mapping rate
echo "1. Lancement de samtools flagstat..."
samtools flagstat -@ $SLURM_CPUS_PER_TASK $BAM > ${TARGET_DIR}/pr_219_${ID}_flagstat.txt

#Global coverage
echo "2. Lancement de mosdepth..."
singularity exec --bind $BREEDMAPS:$BREEDMAPS \
    $container/mosdepth_0.3.13--15918400611933a3.sif \
    mosdepth --threads $SLURM_CPUS_PER_TASK \
    ${TARGET_DIR}/pr_219_${ID}_coverage \
    $BAM

#Targeted coverage
echo "3. Lancement de samtools depth (région ciblée)..."
samtools depth -r 26:14404993-14404993 $BAM > ${TARGET_DIR}/pr_219_${ID}_mutation_depth.txt

echo "End of job QC : $(date)"
