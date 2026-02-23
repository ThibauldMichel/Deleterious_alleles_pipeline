#!/bin/bash

#SBATCH --job-name="fromVCFtoMSA"
#SBATCH --export=ALL
#SBATCH --partition=long

# Load conda into this shell session
source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh

conda activate msa_env  # Activate your conda environment with necessary tools

# === Configuration ===
REF="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"          # Reference genome FASTA
VCF="/home/tmichel/scratch/ROH-pipeline_PNG/calls/all.vcf"        # Multi-sample VCF file (raw)
OUTDIR="output_msa_tree"                                                                 # Output directory base

# === Tools ===
BCFTOOLS=$(which bcftools)
SAMTOOLS=$(which samtools)
SEQTK=$(which seqtk)
IQTREE=$(which iqtree)         # Optional: phylogenetic tree builder

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

# === Step 1: Filter out indels - keep only SNPs ===
echo "Filtering out indels (keep SNPs only)..."
VCF_SNPS="$OUTDIR/tmp/all.snps.vcf.gz"
$BCFTOOLS view -v snps "$VCF" -Oz -o "$VCF_SNPS"
$BCFTOOLS index -f "$VCF_SNPS"

# === Step 2: Normalize SNP-only VCF ===
echo "Normalizing VCF (SNPs only)..."
VCF_NORM="$OUTDIR/tmp/all.norm.vcf.gz"
NORM_LOG="$OUTDIR/tmp/norm.log"

if ! $BCFTOOLS norm -m -both -f "$REF" "$VCF_SNPS" -Oz -o "$VCF_NORM" 2> "$NORM_LOG"; then
  echo "❌ ERROR: bcftools norm failed. Check log: $NORM_LOG"
  exit 1
fi
$BCFTOOLS index -f "$VCF_NORM"

# === Parse normalization log ===
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
  echo "⚠️ Warning: No normalization log found or log is empty."
fi

# === Step 3: Generate pseudo-genome (consensus) FASTAs for each sample ===
echo "Generating consensus FASTAs..."
for SAMPLE in $($BCFTOOLS query -l "$VCF_NORM"); do
  $BCFTOOLS consensus -f "$REF" -s "$SAMPLE" "$VCF_NORM" > "$OUTDIR/consensus_fastas/${SAMPLE}.fa"
done

# === Step 4: Split consensus FASTAs by chromosome ===
echo "Splitting consensus FASTAs by chromosome..."
while read -r CHROM _; do
  for FA in "$OUTDIR"/consensus_fastas/*.fa; do
    SAMPLE=$(basename "$FA" .fa)
    $SEQTK subseq "$FA" <(echo "$CHROM") > "$OUTDIR/per_chrom/${SAMPLE}__${CHROM}.fa"
  done
done < "$REF.fai"

# === Step 5: Create MFA alignments per chromosome ===
echo "Creating MFA alignments per chromosome..."
while read -r CHROM _; do
  MFA="$OUTDIR/mfa_dir/${CHROM}.mfa"
  echo ">reference" > "$MFA"
  $SAMTOOLS faidx "$REF" "$CHROM" | tail -n +2 >> "$MFA"

  for FA in "$OUTDIR"/per_chrom/*__${CHROM}.fa; do
    SAMPLE=$(basename "$FA" .fa | sed "s/__${CHROM}$//")  # remove just the chromosome part
    echo ">$SAMPLE" >> "$MFA"
    tail -n +2 "$FA" >> "$MFA"
  done
done < "$REF.fai"

# === Step 5.5: re-align each chromosome MSA with MAFFT to clean up and improve the alignments.

mkdir -p "$OUTDIR/MSA_realigned"

for msa in "$OUTDIR"/per_chrom/*.mfa ; do
    mafft --auto "$msa" > "$OUTDIR/MSA_realigned/$(basename "$msa")"
done



# === Step 6: Concatenate all MFA alignments ===
echo "Concatenating MFA files..."
cat "$OUTDIR"/MSA_realigned/*.mfa > "$OUTDIR/concat/all_concat_alignment.fasta"

# === Step 7 (Optional): Build phylogenetic tree with IQ-TREE ===
if [ -x "$IQTREE" ]; then
  echo "Building phylogenetic tree with IQ-TREE..."
  pushd "$OUTDIR/concat" > /dev/null
  $IQTREE -s all_concat_alignment.fasta -m GTR+G -nt AUTO -bb 1000
  popd > /dev/null
else
  echo "⚠️ IQ-TREE not found. Skipping tree building."
fi

echo "✅ All done! Outputs in: $OUTDIR"


