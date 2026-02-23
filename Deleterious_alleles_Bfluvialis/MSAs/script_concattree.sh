#!/bin/bash
#SBATCH --job-name=concat_tree
#SBATCH --cpus-per-task=16
#SBATCH --mem=40G
#SBATCH --partition=medium

# Load conda
source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

OUTDIR="output_msa_tree"
IQTREE=$(which iqtree)

# === Step 6: Concatenate all MFA alignments ===
concat_file="$OUTDIR/concat/all_concat_alignment.fasta"
mkdir -p "$OUTDIR/concat"

latest_msa=$(find "$OUTDIR/MSA_realigned" -type f -name "*.mfa" -printf "%T@\n" | sort -n | tail -1)

if [ -s "$concat_file" ] && [ "$concat_file" -nt "$latest_msa" ]; then
    echo "⏩ Skipping concatenation — $concat_file is up to date."
else
    echo "▶️ Concatenating MFA files..."
    cat "$OUTDIR"/MSA_realigned/*.mfa > "$concat_file"
fi

# === Step 7: Build phylogenetic tree with IQ-TREE ===
if [ -x "$IQTREE" ]; then
    treefile="$OUTDIR/concat/all_concat_alignment.fasta.treefile"
    if [ -s "$treefile" ] && [ "$treefile" -nt "$concat_file" ]; then
        echo "⏩ Skipping IQ-TREE — tree is up to date."
    else
        echo "▶️ Building phylogenetic tree with IQ-TREE..."
        pushd "$OUTDIR/concat" > /dev/null
        $IQTREE -s all_concat_alignment.fasta -m MFP -B 1000 --alrt 1000 --bnni --safe --seed 42 --threads "$SLURM_CPUS_PER_TASK"
        popd > /dev/null
    fi
else
    echo "⚠️ IQ-TREE not found. Skipping tree building."
fi

echo "✅ All done! Outputs in: $OUTDIR"

