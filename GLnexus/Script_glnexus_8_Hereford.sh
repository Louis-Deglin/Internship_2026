#!/bin/bash
#SBATCH -A hpc2n2025-261
#SBATCH -J GLnexus_Hereford_2.0
#SBATCH -t 04:00:00
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --mem=120G
#SBATCH -o logs/glnexus_hereford_2.0_%j.out
#SBATCH -e logs/glnexus_hereford_2.0_%j.err
#SBATCH --mail-user=louis.deglin@slu.se
#SBATCH --mail-type=ALL

set -e
set -o pipefail

export BREEDMAPS="/pfs/proj/nobackup/fs/projnb10/hpc2nstor2025-071"
export container="/home/l/louis/container"

OUTDIR="$BREEDMAPS/louis/results/glnexus/hereford/ARS_UCD2.0"
mkdir -p ${OUTDIR}

OUT_PREFIX="cohort_8Hereford_2.0"

GVCFS=""
for ID in 041 042 043 044 045 046 047 048; do
    GVCF=$(ls $BREEDMAPS/louis/results/DeepVariant/Hereford/pr_219_${ID}/*.clean.g.vcf.gz)
    GVCFS="${GVCFS} ${GVCF}"
    echo "Trouvé : ${GVCF}"
done

rm -rf ${OUTDIR}/GLnexus.DB

export SINGULARITYENV_MALLOC_ARENA_MAX=2

singularity exec --bind $BREEDMAPS:$BREEDMAPS \
    $container/glnexus_1.4.1--edcea44cfdd6c68e.sif \
    glnexus_cli \
    --config DeepVariantWGS \
    --threads $SLURM_CPUS_PER_TASK \
    --mem-gbytes 100 \
    --dir ${OUTDIR}/GLnexus.DB \
    ${GVCFS} \
    > ${OUTDIR}/${OUT_PREFIX}.bcf

module load GCC/13.2.0 BCFtools/1.19

echo "Conversion BCF in VCF.gz..."
bcftools view -O z -o ${OUTDIR}/${OUT_PREFIX}.vcf.gz ${OUTDIR}/${OUT_PREFIX}.bcf

echo "Indexation of fianl file..."
bcftools index -t ${OUTDIR}/${OUT_PREFIX}.vcf.gz

