#!/bin/bash
#SBATCH --job-name="msa_merge"
#SBATCH --export=ALL
#SBATCH --partition=long

set -euo pipefail

source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

REF="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"
OUTDIR="output_msa_tree"

SAMTOOLS=$(which samtools)
IQTREE=$(which iqtree)
MAFFT=$(which mafft)

mkdir -p "$OUTDIR"/{mfa_dir,MSA_realigned,concat}

# Step 5 — Build MFA per chromosome
while read -r CHROM _; do
    MFA="$OUTDIR/mfa_dir/${CHROM}.mfa"

    if [ ! -f "$MFA" ]; then
        echo "Building MFA for $CHROM"
        echo ">reference" > "$MFA"
        $SAMTOOLS faidx "$REF" "$CHROM" | tail -n +2 >> "$MFA"

        for FA in "$OUTDIR"/per_chrom/*__${CHROM}.fa; do
            SAMPLE=$(basename "$FA" .fa | sed "s/__${CHROM}$//")
            echo ">$SAMPLE" >> "$MFA"
            tail -n +2 "$FA" >> "$MFA"
        done
    else
        echo "$MFA exists — skipping"
    fi
done < "$REF.fai"

# Step 5.5 — MAFFT realignment
for msa in "$OUTDIR"/mfa_dir/*.mfa; do
    OUT="$OUTDIR/MSA_realigned/$(basename "$msa")"
    if [ ! -f "$OUT" ]; then
        $MAFFT --auto "$msa" > "$OUT"
    fi
done

# Step 6 — Concatenate
CONCAT="$OUTDIR/concat/all_concat_alignment.fasta"
if [ ! -f "$CONCAT" ]; then
    cat "$OUTDIR"/MSA_realigned/*.mfa > "$CONCAT"
fi

# Step 7 — IQTREE
if [ -x "$IQTREE" ]; then
    if [ ! -f "$OUTDIR/concat/all_concat_alignment.fasta.treefile" ]; then
        pushd "$OUTDIR/concat" > /dev/null
        $IQTREE -s all_concat_alignment.fasta -m GTR+G -nt AUTO -bb 1000
        popd > /dev/null
    else
        echo "Tree exists — skipping"
    fi
fi

echo "Done merging + tree."
