#!/bin/bash
#SBATCH --job-name=mafft_trial
#SBATCH --export=ALL
#SBATCH --partition=medium
#SBATCH --cpus-per-task=4   # MAFFT can use multiple threads
#SBATCH --mem=16G



set -eo pipefail

source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

REF="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"
OUTDIR="output_msa_tree"
SAMTOOLS=$(which samtools)
MAFFT=$(which mafft)


CHROM="scaffold1"

MFA="$OUTDIR/mfa_dir/${CHROM}.mfa"
REALIGNED="$OUTDIR/MSA_realigned/${CHROM}.mfa"

# Step 5.5 — MAFFT realignment
echo "Realigning $MFA with MAFFT → $REALIGNED"
$MAFFT --auto "$MFA" > "$REALIGNED"

echo "Done realignment for chromosome $CHROM"
