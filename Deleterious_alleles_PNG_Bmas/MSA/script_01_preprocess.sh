#!/bin/bash
#SBATCH --job-name="msa_preprocess"
#SBATCH --export=ALL
#SBATCH --partition=short

set -euo pipefail

source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

REF="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"
VCF="/home/tmichel/scratch/ROH-pipeline_PNG/calls/all.vcf"
OUTDIR="output_msa_tree"

BCFTOOLS=$(which bcftools)
SAMTOOLS=$(which samtools)

mkdir -p "$OUTDIR"/tmp

VCF_SNPS="$OUTDIR/tmp/all.snps.vcf.gz"
VCF_NORM="$OUTDIR/tmp/all.norm.vcf.gz"

# Index reference
if [ ! -f "$REF.fai" ]; then
    echo "Indexing reference..."
    $SAMTOOLS faidx "$REF"
fi

# Filter SNPs
if [ ! -f "$VCF_SNPS" ]; then
    echo "Filtering SNPs..."
    $BCFTOOLS view -v snps "$VCF" -Oz -o "$VCF_SNPS"
    $BCFTOOLS index -f "$VCF_SNPS"
else
    echo "SNP VCF exists — skipping"
fi

# Normalize
if [ ! -f "$VCF_NORM" ]; then
    echo "Normalizing VCF..."
    $BCFTOOLS norm -m -both -f "$REF" "$VCF_SNPS" -Oz -o "$VCF_NORM"
    $BCFTOOLS index -f "$VCF_NORM"
else
    echo "Normalized VCF exists — skipping"
fi

echo "Done preprocessing."
