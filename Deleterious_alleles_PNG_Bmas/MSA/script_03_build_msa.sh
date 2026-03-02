#!/bin/bash
#SBATCH --job-name="msa_merge"
#SBATCH --export=ALL
#SBATCH --partition=short
#SBATCH --array=1-999%20
#SBATCH --output=logs/msa_merge_%A_%a.out
#SBATCH --error=logs/msa_merge_%A_%a.err

set -euo pipefail

source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

REF="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"
OUTDIR="output_msa_tree"
VCF_NORM="output_msa_tree/tmp/all.norm.vcf.gz"

mkdir -p "$OUTDIR"/{mfa_dir,MSA_realigned}
mkdir -p logs

SAMTOOLS=$(which samtools)
MAFFT=$(which mafft)
BCFTOOLS=$(which bcftools)

# -----------------------------
# Get chromosome list from VCF
# -----------------------------
CHROM=$( $BCFTOOLS query -f '%CHROM\n' "$VCF_NORM" | sort -u | sed -n "${SLURM_ARRAY_TASK_ID}p" )

if [ -z "$CHROM" ]; then
    echo "No chromosome for task $SLURM_ARRAY_TASK_ID — exiting."
    exit 0
fi

echo "Processing chromosome: $CHROM"

# -----------------------------
# Step 5 — Build MFA
# -----------------------------
MFA="$OUTDIR/mfa_dir/${CHROM}.mfa"

if [ ! -f "$MFA" ]; then
    echo "Building MFA for $CHROM"
    echo ">reference" > "$MFA"
    $SAMTOOLS faidx "$REF" "$CHROM" | tail -n +2 >> "$MFA"

    for FA in "$OUTDIR"/per_chrom/*__${CHROM}.fa; do
        [ -e "$FA" ] || continue
        SAMPLE=$(basename "$FA" .fa | sed "s/__${CHROM}$//")
        echo ">$SAMPLE" >> "$MFA"
        tail -n +2 "$FA" >> "$MFA"
    done
else
    echo "$MFA exists — skipping"
fi

# -----------------------------
# Step 5.5 — MAFFT realignment
# -----------------------------
OUT="$OUTDIR/MSA_realigned/${CHROM}.mfa"

if [ ! -f "$OUT" ]; then
    echo "Running MAFFT for $CHROM"
    $MAFFT --auto "$MFA" > "$OUT"
else
    echo "$OUT exists — skipping"
fi

echo "Done chromosome $CHROM."
