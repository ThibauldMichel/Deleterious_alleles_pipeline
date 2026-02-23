#!/bin/bash

#SBATCH --job-name="fromVCFtoMSA"
#SBATCH --export=ALL
#SBATCH --mem=200G
#SBATCH --partition=medium

source activate msa_env  # Activate your conda environment with necessary tools


# === Configuration ===
REF="/home/tmichel/scratch/ROH-pipeline/ROH-pipeline_Bfluvialis/Bflu_genome.fa"          # Path to reference genome FASTA
VCF="/home/tmichel/scratch/ROH-pipeline/ROH-pipeline_Bfluvialis/calls/all.vcf"             # Multi-sample VCF file
OUTDIR="output_msa_tree"       # Base output directory for all results

# === Tools ===
BCFTOOLS=$(which bcftools)
SAMTOOLS=$(which samtools)
SEQTK=$(which seqtk)
IQTREE=$(which iqtree)         # Optional, only if you want the tree

# === Create directories ===
mkdir -p "$OUTDIR"/{consensus_fastas,per_chrom,mfa_dir,concat}

# === Step 0: Index reference (if needed) ===
if [ ! -f "$REF.fai" ]; then
  echo "Indexing reference..."
  $SAMTOOLS faidx "$REF"
fi

# === Step 1: Generate pseudo-genome (consensus) FASTAs ===
echo "Generating consensus FASTAs..."
for SAMPLE in $($BCFTOOLS query -l "$VCF"); do
  $BCFTOOLS consensus -f "$REF" -s "$SAMPLE" "$VCF" > "$OUTDIR/consensus_fastas/${SAMPLE}.fa"
done

# === Step 2: Split pseudo-genomes per chromosome ===
echo "Splitting consensus FASTAs by chromosome..."
while read CHROM _; do
  for FA in "$OUTDIR"/consensus_fastas/*.fa; do
    SAMPLE=$(basename "$FA" .fa)
    $SEQTK subseq "$FA" <(echo "$CHROM") > "$OUTDIR/per_chrom/${SAMPLE}__${CHROM}.fa"
  done
done < "$REF.fai"

# === Step 3: Create MFA alignments per chromosome ===
echo "Creating MFA alignments per chromosome..."
while read CHROM _; do
  MFA="$OUTDIR/mfa_dir/${CHROM}.mfa"
  echo ">reference" > "$MFA"
  $SAMTOOLS faidx "$REF" "$CHROM" | tail -n +2 >> "$MFA"

  for FA in "$OUTDIR"/per_chrom/*__${CHROM}.fa; do
    SAMPLE=$(basename "$FA" | cut -d'_' -f1)
    echo ">$SAMPLE" >> "$MFA"
    tail -n +2 "$FA" >> "$MFA"
  done
done < "$REF.fai"

# === Step 4 (Optional): Concatenate all MFA files into one alignment ===
echo "Concatenating MFA files..."
cat "$OUTDIR"/mfa_dir/*.mfa > "$OUTDIR/concat/all_concat_alignment.fasta"

# === Step 5 (Optional): Build tree using IQ-TREE ===
if [ -x "$IQTREE" ]; then
  echo "Building phylogenetic tree with IQ-TREE..."
  pushd "$OUTDIR/concat" > /dev/null
  $IQTREE -s all_concat_alignment.fasta -m GTR+G -nt AUTO -bb 1000
  popd > /dev/null
else
  echo "IQ-TREE not found. Skipping tree building."
fi

echo "✅ All done! Outputs in: $OUTDIR"
