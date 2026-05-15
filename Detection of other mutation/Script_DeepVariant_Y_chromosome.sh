#!/bin/bash
#SBATCH -A hpc2n2025-261
#SBATCH -J DV_Bonsmara_Y
#SBATCH -t 04:00:00
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --mem=240G
#SBATCH --array=0-7
#SBATCH -o logs/deepvariant_chrY_%A_%a.out
#SBATCH -e logs/deepvariant_chrY_%A_%a.err
#SBATCH --mail-user=louis.deglin@slu.se
#SBATCH --mail-type=ALL

set -e
set -o pipefail

export BREEDMAPS="/pfs/proj/nobackup/fs/projnb10/hpc2nstor2025-071"
export container="/home/l/louis/container"

SAMPLE_IDS=(033 034 035 036 037 038 039 040)
ID=${SAMPLE_IDS[$SLURM_ARRAY_TASK_ID]}

INDIR=$BREEDMAPS/louis/results/pbmm2/ARS-UCD2.0/pr_219_${ID}

BAM=$(ls ${INDIR}/Aligned_*.bam | head -1)
BAM_NAME=$(basename $BAM)

OUTDIR=$BREEDMAPS/louis/results/DeepVariant/Bonsmara_Y/pr_219_${ID}
TMP_DIR=$OUTDIR/tmp_${ID}

mkdir -p $OUTDIR
mkdir -p $TMP_DIR
rm -rf $TMP_DIR/*

singularity exec --bind $BREEDMAPS:$BREEDMAPS \
    --env TMPDIR=$TMP_DIR \
    $container/deepvariant_1.8.0.sif \
    /opt/deepvariant/bin/run_deepvariant \
    --model_type PACBIO \
    --ref $BREEDMAPS/louis/reference/Bos_taurus.ARS-UCD2.0.dna.toplevel.fa \
    --reads $BAM \
    --output_vcf $OUTDIR/pr_219_${ID}_chrY.deepvariant.vcf.gz \
    --output_gvcf $OUTDIR/pr_219_${ID}_chrY.deepvariant.g.vcf.gz \
    --intermediate_results_dir $TMP_DIR \
    --num_shards $SLURM_CPUS_PER_TASK \
    --regions "Y"

