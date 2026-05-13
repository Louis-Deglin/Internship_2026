#!/bin/bash
#SBATCH -A hpc2n2025-261
#SBATCH -t 12:00:00
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem=64G
#SBATCH -J pbmm2_hereford
#SBATCH --array=0-7
#SBATCH -o logs/pbmm2_hereford_2.0_%A_%a.out
#SBATCH -e logs/pbmm2_hereford_2.0_%A_%a.err
#SBATCH --mail-user=louis.deglin@slu.se
#SBATCH --mail-type=ALL

export BREEDMAPS="/pfs/proj/nobackup/fs/projnb10/hpc2nstor2025-071"
export container="/home/l/louis/container"

SAMPLE_IDS=(041 042 043 044 045 046 047 048)
ID=${SAMPLE_IDS[$SLURM_ARRAY_TASK_ID]}

SAMPLE_DIR=$BREEDMAPS/louis/data/Hifi.Batch02.pr_219/pr_219_${ID}

BAM=$(ls ${SAMPLE_DIR}/*.bam | grep -v '.pbi' | head -1)
BAM_NAME=$(basename $BAM)

OUTDIR=$BREEDMAPS/louis/results/pbmm2/Hereford/pr_219_${ID}
mkdir -p ${OUTDIR}

echo "=== pr_219_${ID} === BAM: ${BAM_NAME} === $(date) ==="

singularity exec --bind $BREEDMAPS:$BREEDMAPS \
    $container/pbmm2_26.1.0--d08c39588d4e31e5.sif \
    pbmm2 align \
    $BREEDMAPS/louis/reference/Bos_taurus.ARS-UCD2.0.dna.toplevel.fa \
    ${BAM} \
    ${OUTDIR}/Aligned_${BAM_NAME} \
    -j $SLURM_CPUS_PER_TASK \
    --sort

echo "Fin: $(date)"
