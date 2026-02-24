#!/bin/bash
#SBATCH --job-name=msa_chrom
#SBATCH --export=ALL
#SBATCH --partition=long
#SBATCH --array=0-999%20   # We'll adjust the range dynamically
#SBATCH --cpus-per-task=4   # MAFFT can use multiple threads
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --output=logs/mfa_%A_%a.out
#SBATCH --error=logs/mfa_%A_%a.err

set -eo pipefail

source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

REF="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"
OUTDIR="output_msa_tree"
SAMTOOLS=$(which samtools)
MAFFT=$(which mafft)

mkdir -p "$OUTDIR/mfa_dir"
mkdir -p "$OUTDIR/MSA_realigned"
mkdir -p logs

# --- Get list of chromosomes ---
mapfile -t CHROMS < <(cut -f1 "$REF.fai")

# Safety check: exit if array index is too high
if [ "$SLURM_ARRAY_TASK_ID" -ge "${#CHROMS[@]}" ]; then
    echo "No chromosome for this task ID"
    exit 0
fi

CHROM=${CHROMS[$SLURM_ARRAY_TASK_ID]}
MFA="$OUTDIR/mfa_dir/${CHROM}.mfa"
REALIGNED="$OUTDIR/MSA_realigned/${CHROM}.mfa"

# Skip if already realigned MFA exists
if [ -f "$REALIGNED" ]; then
    echo "$REALIGNED exists — skipping"
    exit 0
fi

echo "Building MFA for chromosome: $CHROM"

# Step 5 — Build MFA
echo ">reference" > "$MFA"
$SAMTOOLS faidx "$REF" "$CHROM" | tail -n +2 >> "$MFA"

for FA in "$OUTDIR"/per_chrom/*__${CHROM}.fa; do
    SAMPLE=$(basename "$FA" .fa | sed "s/__${CHROM}$//")
    echo ">$SAMPLE" >> "$MFA"
    tail -n +2 "$FA" >> "$MFA"
done

echo "Done MFA for chromosome $CHROM"

# Step 5.5 — MAFFT realignment
echo "Realigning $MFA with MAFFT → $REALIGNED"
$MAFFT --auto "$MFA" > "$REALIGNED"

echo "Done realignment for chromosome $CHROM"
