#!/bin/bash
#SBATCH -A hpc2n2025-261
#SBATCH -J DV_brahman
#SBATCH -t 48:00:00
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --mem=120G
#SBATCH --array=0-7
#SBATCH -o logs/deepvariant_brahman_%A_%a.out
#SBATCH -e logs/deepvariant_brahman_%A_%a.err
#SBATCH --mail-user=louis.deglin@slu.se
#SBATCH --mail-type=ALL

set -e
set -o pipefail

export BREEDMAPS="/pfs/proj/nobackup/fs/projnb10/hpc2nstor2025-071"
export container="/home/l/louis/container"

SAMPLE_IDS=(033 034 035 036 037 038 039 040)
ID=${SAMPLE_IDS[$SLURM_ARRAY_TASK_ID]}

INDIR=$BREEDMAPS/louis/results/pbmm2/UOA_Brahman_1/pr_219_${ID}

BAM=$(ls ${INDIR}/Aligned_*.bam | head -1)
BAM_NAME=$(basename $BAM)

OUTDIR=$BREEDMAPS/louis/results/DeepVariant/UOA_Brahman_1/pr_219_${ID}
TMP_DIR=$OUTDIR/tmp_${ID}

mkdir -p $OUTDIR
mkdir -p $TMP_DIR
rm -rf $TMP_DIR/*

singularity exec --bind $BREEDMAPS:$BREEDMAPS \
    --env TMPDIR=$TMP_DIR \
    $container/deepvariant_1.8.0.sif \
    /opt/deepvariant/bin/run_deepvariant \
    --model_type PACBIO \
    --ref $BREEDMAPS/louis/reference/Bos_indicus_hybrid.UOA_Brahman_1.dna.toplevel.fa \
    --reads $BAM \
    --output_vcf $OUTDIR/pr_219_${ID}.deepvariant.vcf.gz \
    --output_gvcf $OUTDIR/pr_219_${ID}.deepvariant.g.vcf.gz \
    --intermediate_results_dir $TMP_DIR \
    --num_shards $SLURM_CPUS_PER_TASK \
    --regions "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 X"

