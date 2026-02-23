#!/bin/bash

#SBATCH --job-name="fromVCFtoMSA"
#SBATCH --export=ALL
#SBATCH --mem=200G
#SBATCH --partition=medium

conda activate msa_env  # Activate your conda environment with necessary tools


# === Configuration ===
REF="/home/tmichel/scratch/ROH-pipeline/ROH-pipeline_Bfluvialis/Bflu_genome.fa"          # Path to reference genome FASTA
VCF="/home/tmichel/scratch/ROH-pipeline/ROH-pipeline_Bfluvialis/calls/all.vcf.gz"             # Multi-sample VCF file
OUTDIR="output_msa_tree"       # Base output directory for all results




# === Tools ===
BCFTOOLS=$(which bcftools)
SAMTOOLS=$(which samtools)
SEQTK=$(which seqtk)
IQTREE=$(which iqtree)         # Optional, only if you want the tree



# === Check inputs ===
if [ ! -f "$REF" ]; then
  echo "❌ Reference genome not found at: $REF"
  exit 1
fi

if [ ! -f "$VCF" ]; then
  echo "❌ VCF not found at: $VCF"
  exit 1
fi

# === Create output directories ===
mkdir -p "$OUTDIR"/{consensus_fastas,per_chrom,mfa_dir,concat,tmp}

# === Step 0: Index reference (if needed) ===
if [ ! -f "$REF.fai" ]; then
  echo "Indexing reference..."
  $SAMTOOLS faidx "$REF"
fi

# === Step 1: Normalize VCF ===
echo "Normalizing VCF..."

# === Ensure OUTDIR is set ===
if [ -z "$OUTDIR" ]; then
  echo "❌ ERROR: OUTDIR is not set. Exiting."
  exit 1
fi

mkdir -p "$OUTDIR/tmp"

echo "Normalizing VCF..."
VCF_NORM="$OUTDIR/tmp/all.norm.vcf.gz"
NORM_LOG="$OUTDIR/tmp/norm.log"

# Perform normalization and check if it succeeds
if ! $BCFTOOLS norm -m -both -f "$REF" "$VCF" -Oz -o "$VCF_NORM" 2> "$NORM_LOG"; then
  echo "❌ ERROR: bcftools norm failed. Check log: $NORM_LOG"
  exit 1
fi

# Index the normalized VCF (with -f in case it's required)
$BCFTOOLS index -f "$VCF_NORM"

# === Parse normalization log to count affected loci ===
if [ -s "$NORM_LOG" ]; then
  COUNTS_LINE=$(grep -oP 'Lines\s+total/split/joined/realigned/mismatch_removed/dup_removed/skipped:\s+\K.+' "$NORM_LOG")
  IFS='/' read -r TOTAL SPLIT JOINED REALIGNED MISMATCH_REMOVED DUP_REMOVED SKIPPED <<< "$COUNTS_LINE"

  echo "Normalization summary:"
  echo "  Total lines processed:           $TOTAL"
  echo "  Split multiallelics:             $SPLIT"
  echo "  Realigned (left-normalized):     $REALIGNED"
  echo "  Mismatch removed:                $MISMATCH_REMOVED"
  echo "  Duplicate removed:               $DUP_REMOVED"
  echo "  Skipped:                         $SKIPPED"

  AFFECTED=$((SPLIT + REALIGNED + MISMATCH_REMOVED + DUP_REMOVED))
  echo "  👉 Total affected loci (normalized/removed): $AFFECTED"
else
  echo "⚠️  Warning: No normalization log found or log is empty."
fi










# === Step 2: Generate pseudo-genome (consensus) FASTAs ===
echo "Generating consensus FASTAs..."
for SAMPLE in $($BCFTOOLS query -l "$VCF_NORM"); do
  $BCFTOOLS consensus -f "$REF" -s "$SAMPLE" "$VCF_NORM" > "$OUTDIR/consensus_fastas/${SAMPLE}.fa"
done

# === Step 3: Split pseudo-genomes per chromosome ===
echo "Splitting consensus FASTAs by chromosome..."
while read -r CHROM _; do
  for FA in "$OUTDIR"/consensus_fastas/*.fa; do
    SAMPLE=$(basename "$FA" .fa)
    $SEQTK subseq "$FA" <(echo "$CHROM") > "$OUTDIR/per_chrom/${SAMPLE}__${CHROM}.fa"
  done
done < "$REF.fai"

# === Step 4: Create MFA alignments per chromosome ===
echo "Creating MFA alignments per chromosome..."
while read -r CHROM _; do
  MFA="$OUTDIR/mfa_dir/${CHROM}.mfa"
  echo ">reference" > "$MFA"
  $SAMTOOLS faidx "$REF" "$CHROM" | tail -n +2 >> "$MFA"

  for FA in "$OUTDIR"/per_chrom/*__${CHROM}.fa; do
    SAMPLE=$(basename "$FA" | cut -d'_' -f1)
    echo ">$SAMPLE" >> "$MFA"
    tail -n +2 "$FA" >> "$MFA"
  done
done < "$REF.fai"

# === Step 5 (Optional): Concatenate MFA files into one alignment ===
echo "Concatenating MFA files..."
cat "$OUTDIR"/mfa_dir/*.mfa > "$OUTDIR/concat/all_concat_alignment.fasta"

# === Step 6 (Optional): Build tree using IQ-TREE ===
if [ -x "$IQTREE" ]; then
  echo "Building phylogenetic tree with IQ-TREE..."
  pushd "$OUTDIR/concat" > /dev/null
  $IQTREE -s all_concat_alignment.fasta -m GTR+G -nt AUTO -bb 1000
  popd > /dev/null
else
  echo "⚠️ IQ-TREE not found. Skipping tree building."
fi

echo "✅ All done! Outputs in: $OUTDIR"
