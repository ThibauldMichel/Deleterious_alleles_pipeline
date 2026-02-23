#!/bin/bash
#SBATCH --job-name=mafft_array
#SBATCH --array=3,13,18,23,31,36,46,48,74,96,108,126,168,182,186,301
#SBATCH --partition=long
#SBATCH --cpus-per-task=8
#SBATCH --mem=10G




# Load conda
source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh
conda activate msa_env

OUTDIR="output_msa_tree/MSA_realigned"
IN_DIR="output_msa_tree/mfa_dir"

mkdir -p "$OUTDIR"

# Format ID to match filenames
ID=$(printf "%06d" "$SLURM_ARRAY_TASK_ID")
infile="$IN_DIR/ptg${ID}l.mfa"
outfile="$OUTDIR/ptg${ID}l.mfa"

if [ -s "$outfile" ] && [ "$outfile" -nt "$infile" ]; then
    echo "⏩ Skipping MAFFT for ptg${ID}l.mfa — up to date."
else
    echo "▶️ Aligning ptg${ID}l.mfa with MAFFT..."
    mafft --thread "$SLURM_CPUS_PER_TASK" --large --parttree --retree 2 --maxiterate 2 "$infile" > "$outfile"
fi




# --retree 2
# This flag controls the number of reconstructed guide trees during the progressive alignment stage.
# MAFFT first builds an initial guide tree (often using a fast method like UPGMA based on a rough distance matrix).
# It then performs an initial progressive alignment based on that tree.
# The --retree 2 option takes this aligned result and uses it to build a new, more accurate guide tree. This new tree is based on the actual similarities in the initial alignment, which is better than the initial rough distances.
# Finally, MAFFT performs the progressive alignment again, but this time using the new, more accurate guide tree.
# Why use it: Rebuilding the tree leads to a significantly more accurate final alignment because the guide tree is better informed. The number 2 is a good balance; --retree 1 would skip this step (less accurate), and higher numbers (e.g., --retree 10) would repeat the process multiple times for diminishing returns and much longer runtimes.

# --maxiterate 2
# What it means: This flag controls the number of iterative refinement cycles performed after the progressive alignment.
# After building the initial progressive alignment (potentially with a rebuilt tree from --retree), MAFFT has a complete multiple sequence alignment (MSA).
# Iterative refinement aims to improve this MSA by repeatedly realigning subsets of sequences and checking if the change improves the overall alignment score. It tries to fix misalignments that can occur in the initial progressive pass.
# --maxiterate 2 means it will perform 2 cycles of this refinement.
# Why use it: Iterative refinement consistently improves alignment accuracy. Again, 2 is a practical choice. --maxiterate 0 would skip refinement (faster, less accurate), while --maxiterate 1000 would continue until no more improvements are found (much slower, only marginally more accurate).

# The --parttree Flag
# Purpose: To drastically speed up the initial guide tree construction for datasets containing a large number of sequences (e.g., thousands).
# Standard Problem: Building a guide tree requires calculating a distance matrix between every pair of sequences. This has a time complexity of O(N²), meaning the computation time increases with the square of the number of sequences. For 10,000 sequences, this means ~50 million pairwise comparisons, which is very slow.
# PartTree Solution: The --parttree algorithm is a heuristic method that avoids calculating all pairwise distances. It works by:
# Grouping similar sequences: It first quickly clusters sequences into groups based on a rough measure of similarity (like k-mer counts).
# Calculating representative distances: Instead of comparing every sequence to every other sequence, it calculates distances between group representatives and between sequences in the same group.
# Building the tree: It uses this reduced set of calculations to build the guide tree.

# The --large Flag
# Purpose: To enable a workflow that is optimized for large datasets, both in terms of the number of sequences and their lengths.
#    --parttree: As described above, to handle a large number of sequences.

 #   Memsave Mode: It forces the use of the "memsave" mode for the progressive alignment stage. This mode uses a more memory-efficient (but slightly slower) algorithm for the dynamic programming (DP) step when aligning two large profiles.

  #  Other Optimizations: It may adjust other internal parameters to prioritize memory usage and stability over sheer speed for very large operations.
