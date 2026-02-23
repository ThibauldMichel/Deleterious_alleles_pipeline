#!/bin/bash

#SBATCH --job-name="convertfnajson"
#SBATCH --export=ALL
#SBATCH --mem=200G
#SBATCH --partition=short






while read file; do rsync -azvh output_meme/"$file"_MEME.fna output_meme/"$file".json ; done < mfa_files.txt
