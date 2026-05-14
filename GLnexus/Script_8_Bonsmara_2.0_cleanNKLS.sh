#!/bin/bash
#SBATCH -A hpc2n2025-261
#SBATCH -J Clean_NKLS_Bons_2.0
#SBATCH -t 00:30:00
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=32G
#SBATCH -o logs/clean_nkls_bons_2.0_%j.out
#SBATCH -e logs/clean_nkls_bons_2.0_%j.err
#SBATCH --mail-user=louis.deglin@slu.se
#SBATCH --mail-type=ALL

set -e
set -o pipefail

module load GCC/13.2.0 BCFtools/1.19

export BREEDMAPS="/pfs/proj/nobackup/fs/projnb10/hpc2nstor2025-071"

BASE_DIR="$BREEDMAPS/louis/results/DeepVariant/ARS-UCD2.0"

for ID in 033 034 035 036 037 038 039 040; do

    DIR="${BASE_DIR}/pr_219_${ID}"
    ORIGINAL_VCF="${DIR}/pr_219_${ID}.deepvariant.g.vcf.gz"
    CLEANED_VCF="${DIR}/pr_219_${ID}.clean.g.vcf.gz"

    bcftools view -h $ORIGINAL_VCF > ${DIR}/header.txt
    grep -v "ID=NKLS" ${DIR}/header.txt > ${DIR}/clean_header.txt
    bcftools reheader -h ${DIR}/clean_header.txt -o $CLEANED_VCF $ORIGINAL_VCF

    bcftools index -t $CLEANED_VCF

    rm ${DIR}/header.txt ${DIR}/clean_header.txt

    echo "-> Cleaned file : $CLEANED_VCF"
done

