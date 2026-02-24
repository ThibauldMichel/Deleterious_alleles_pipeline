#!/bin/bash
#SBATCH --job-name=bwa_mem_batch
#SBATCH --output=logs/bwa_mem_array_%A_%a.out
#SBATCH --error=logs/bwa_mem_array_%A_%a.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=long

# -------------------------------------------------
# Activate environment
# -------------------------------------------------
source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate snakemake_env

# -------------------------------------------------
# Input: a file "samples.txt" with one sample name per line.
# The array index will pick a sample.
# -------------------------------------------------
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)

echo "Running BWA MEM for sample: $SAMPLE"
echo "SLURM job ID: $SLURM_JOB_ID"
echo "Array task ID: $SLURM_ARRAY_TASK_ID"

# -------------------------------------------------
# Input reads (the same filenames Snakemake uses)
# -------------------------------------------------
R1="trimmed/${SAMPLE}_1_paired.fastq.gz"
R2="trimmed/${SAMPLE}_2_paired.fastq.gz"

# -------------------------------------------------
# Output file
# -------------------------------------------------
OUT="mapped/${SAMPLE}.bam"

# Create output dir if not existing
mkdir -p mapped
mkdir -p logs/bwa_mem

# -------------------------------------------------
# Reference prefix (must already be indexed)
# If your Snakemake config is config["reference"], set it here:
# -------------------------------------------------
REFERENCE="genome"   # e.g. "reference/genome.fasta" without .fasta for index prefix

# -------------------------------------------------
# Run BWA MEM + pipe to samtools view > BAM
# -------------------------------------------------
bwa mem \
    -t ${SLURM_CPUS_PER_TASK} \
    -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}" \
    ${REFERENCE} \
    ${R1} ${R2} \
    | samtools view -@ ${SLURM_CPUS_PER_TASK} -bS - \
    > ${OUT}

echo "Finished sample: $SAMPLE"

