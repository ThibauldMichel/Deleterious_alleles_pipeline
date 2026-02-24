#!/bin/bash
#SBATCH --job-name=bwa_mem_batch
#SBATCH --output=logs/bwa_mem_array_%A_%a.out
#SBATCH --error=logs/bwa_mem_array_%A_%a.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=medium
#SBATCH --array=1-190%20

# -------------------------------------------------
# Activate environment
# -------------------------------------------------
source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate snakemake_env

# -------------------------------------------------
# Sample selection (strip whitespace / CR)
# -------------------------------------------------
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt | tr -d '\r' | awk '{$1=$1;print}')
if [[ -z "$SAMPLE" ]]; then
    echo "ERROR: SAMPLE is empty. Check samples.txt and SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

echo "=== HaplotypeCaller ==="
echo "Sample: $SAMPLE"
echo "SLURM_JOBID: $SLURM_JOB_ID"
echo "SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"
echo "CPUS: ${SLURM_CPUS_ON_NODE:-$SLURM_CPUS_PER_TASK}"

# -------------------------------------------------
# Paths / filenames - adjust REFERENCE if needed
# -------------------------------------------------
REFERENCE="/home/tmichel/projects/rbge/tmichel/reference_genomes/Bmas.fa"
BAM="mapped/${SAMPLE}.sorted.bam"
BAI="${BAM}.bai"
OUT="calls/${SAMPLE}.g.vcf"
LOGDIR="logs/gatk/haplotypecaller"
LOG="${LOGDIR}/${SAMPLE}.log"

mkdir -p "$(dirname "$OUT")"
mkdir -p "$LOGDIR"

# -------------------------------------------------
# Quick checks
# -------------------------------------------------
if [[ -f "$OUT" ]]; then
    echo "Output exists: $OUT  — skipping."
    exit 0
fi

if [[ ! -f "$BAM" ]]; then
    echo "ERROR: BAM not found: $BAM" >&2
    exit 1
fi

if [[ ! -f "$BAI" ]]; then
    echo "ERROR: BAM index not found: $BAI" >&2
    exit 1
fi

if [[ ! -f "$REFERENCE" ]]; then
    echo "ERROR: Reference not found: $REFERENCE" >&2
    exit 1
fi

# check for fasta index and dict
if [[ ! -f "${REFERENCE}.fai" ]]; then
    echo "ERROR: Reference FASTA index missing: ${REFERENCE}.fai" >&2
    echo "Run: samtools faidx $REFERENCE" >&2
    exit 1
fi

# expected dict names: basename.dict (e.g. Bmas.dict) or same name .dict
DICT="${REFERENCE%.*}.dict"
if [[ ! -f "$DICT" ]]; then
    echo "ERROR: Reference sequence dictionary missing: $DICT" >&2
    echo "Run: gatk CreateSequenceDictionary -R $REFERENCE -O $DICT" >&2
    exit 1
fi

# -------------------------------------------------
# Compute Java heap (leave some RAM for OS): use 75% of SLURM memory if available
# -------------------------------------------------
# SLURM provides memory in MB via SLURM_MEM_PER_NODE/SLURM_MEM_PER_CPU or --mem (we requested 16G)
JAVA_XMX="12G"   # safe default
if [[ -n "${SLURM_MEM_PER_NODE:-}" ]]; then
    # convert to GB and take ~75%
    mem_gb=$(( SLURM_MEM_PER_NODE / 1024 ))
    heap_gb=$(( mem_gb * 75 / 100 ))
    [[ $heap_gb -ge 2 ]] && JAVA_XMX="${heap_gb}G"
fi

echo "Using Java heap: -Xmx${JAVA_XMX}"

# -------------------------------------------------
# Run GATK HaplotypeCaller (emit GVCF)
# -------------------------------------------------
# Use native pair-hmm threads equal to SLURM_CPUS_PER_TASK or 4 if not set.
NATIVE_THREADS=${SLURM_CPUS_PER_TASK:-4}

echo "Running: gatk --java-options \"-Xmx${JAVA_XMX}\" HaplotypeCaller (threads=${NATIVE_THREADS})"
gatk --java-options "-Xmx${JAVA_XMX}" HaplotypeCaller \
    --native-pair-hmm-threads "${NATIVE_THREADS}" \
    -R "$REFERENCE" \
    -I "$BAM" \
    -O "$OUT" \
    -ERC GVCF \
    > "$LOG" 2>&1

rc=$?
if [[ $rc -ne 0 ]]; then
    echo "HaplotypeCaller failed for $SAMPLE (exit $rc). See $LOG" >&2
    exit $rc
fi

echo "HaplotypeCaller finished for $SAMPLE -> $OUT"

