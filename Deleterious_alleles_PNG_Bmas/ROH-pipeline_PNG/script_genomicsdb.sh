#!/bin/bash
#SBATCH --job-name=genomicsdbimport
#SBATCH --output=logs/genomicsdbimport.out
#SBATCH --error=logs/genomicsdbimport.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --partition=medium

# -------------------------------
# Activate environment
# -------------------------------
source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate snakemake_env

# -------------------------------
# Input reference genome
# -------------------------------
REFERENCE="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"

# -------------------------------
# Step 1: Produce interval list
# -------------------------------
echo "Producing intervals_edit.list ..."
cat "$REFERENCE" | grep ">" | sed 's/>//' > intervals_edit.list

echo "intervals_edit.list created:"
head intervals_edit.list

# -------------------------------
# Step 2: Prepare GVCF list
# -------------------------------
echo "Collecting GVCFs..."
GVCF_DIR="calls"

# Find all *.g.vcf files
GVCFS=$(ls ${GVCF_DIR}/*.g.vcf)

echo "Found the following GVCFs:"
echo "$GVCFS"

# -------------------------------
# Step 3: Run GenomicsDBImport
# -------------------------------
echo "Running GATK GenomicsDBImport..."

gatk --java-options "-Xmx28G" GenomicsDBImport \
    --genomicsdb-workspace-path db \
    --batch-size 50 \
    --reader-threads ${SLURM_CPUS_PER_TASK} \
    --intervals intervals_edit.list \
    --tmp-dir /tmp \
    $(for f in $GVCFS; do echo "-V $f"; done) \
    > logs/gatk_genomicsdbimport.log 2>&1

echo "GenomicsDBImport completed."

echo "DB directory created:"
ls -l db

