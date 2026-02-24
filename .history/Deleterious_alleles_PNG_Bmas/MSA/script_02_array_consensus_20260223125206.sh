#!/bin/bash
#SBATCH --job-name="msa_array"
#SBATCH --export=ALL
#SBATCH --partition=short
#SBATCH --array=0-999%20

set -euo pipefail

source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

REF="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"
VCF_NORM="output_msa_tree/tmp/all.norm.vcf.gz"
OUTDIR="output_msa_tree"

BCFTOOLS=$(which bcftools)
SAMTOOLS=$(which samtools)
SEQTK=$(which seqtk)

mkdir -p "$OUTDIR"/{consensus_fastas,per_chrom}

# Get sample list
mapfile -t SAMPLES < <($BCFTOOLS query -l "$VCF_NORM")

if [ "$SLURM_ARRAY_TASK_ID" -ge "${#SAMPLES[@]}" ]; then
    echo "No sample for this task ID"
    exit 0
fi

SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}
echo "Processing sample: $SAMPLE"

FA="$OUTDIR/consensus_fastas/${SAMPLE}.fa"

# Step 3 — Consensus
if [ ! -f "$FA" ]; then
    echo "Generating consensus..."
    $BCFTOOLS consensus -f "$REF" -s "$SAMPLE" "$VCF_NORM" > "$FA"
else
    echo "Consensus exists — skipping"
fi

# Step 4 — Split by chromosome
while read -r CHROM _; do
    OUTFA="$OUTDIR/per_chrom/${SAMPLE}__${CHROM}.fa"
    if [ ! -f "$OUTFA" ]; then
        $SEQTK subseq "$FA" <(echo "$CHROM") > "$OUTFA"
    fi
done < "$REF.fai"

echo "Done sample $SAMPLE"
