#!/bin/bash
#SBATCH --job-name="msa_merge"
#SBATCH --export=ALL
#SBATCH --partition=long
#SBATCH --array=1-200%20   # Array for 200 samples, max 20 running at once
#SBATCH --output=logs/msa_merge_%A_%a.out
#SBATCH --error=logs/msa_merge_%A_%a.err

set -euo pipefail

# Load conda and environment
source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

# Paths
REF="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"
OUTDIR="output_msa_tree"
mkdir -p "$OUTDIR"/{mfa_dir,MSA_realigned}
mkdir -p logs

SAMTOOLS=$(which samtools)
MAFFT=$(which mafft)

# Map SLURM_ARRAY_TASK_ID to a sample or chromosome
# For simplicity, assume you have a file "chrom_list.txt" with all chromosomes
CHROM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" chrom_list.txt)

# Step 5 — Build MFA per chromosome
MFA="$OUTDIR/mfa_dir/${CHROM}.mfa"

if [ ! -f "$MFA" ]; then
    echo "[$SLURM_ARRAY_TASK_ID] Building MFA for $CHROM"
    echo ">reference" > "$MFA"
    $SAMTOOLS faidx "$REF" "$CHROM" | tail -n +2 >> "$MFA"

    for FA in "$OUTDIR"/per_chrom/*__${CHROM}.fa; do
        SAMPLE=$(basename "$FA" .fa | sed "s/__${CHROM}$//")
        echo ">$SAMPLE" >> "$MFA"
        tail -n +2 "$FA" >> "$MFA"
    done
else
    echo "[$SLURM_ARRAY_TASK_ID] $MFA exists — skipping"
fi

# Step 5.5 — MAFFT realignment
OUT="$OUTDIR/MSA_realigned/${CHROM}.mfa"
if [ ! -f "$OUT" ]; then
    echo "[$SLURM_ARRAY_TASK_ID] Realigning $MFA with MAFFT"
    $MAFFT --auto "$MFA" > "$OUT"
else
    echo "[$SLURM_ARRAY_TASK_ID] $OUT exists — skipping"
fi

echo "[$SLURM_ARRAY_TASK_ID] Done processing $CHROM."
