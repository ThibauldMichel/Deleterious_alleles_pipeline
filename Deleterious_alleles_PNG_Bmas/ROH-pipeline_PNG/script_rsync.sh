#!/bin/bash
#SBATCH --job-name="rsynccapt"
#SBATCH --export=ALL  
#SBATCH --partition=short


mkdir raw_reads

# Path to Hillebrandia reads:
rsync -azvh  /home/tmichel/projects/rbge/Begonia_genomes/Hillebrandia_illumina/hillebrandia_forward_paired.fq.gz ./reads/
rsync -azvh  /home/tmichel/projects/rbge/Begonia_genomes/Hillebrandia_illumina/hillebrandia_reverse_paired.fq.gz ./reads/

# Path to PNG reads:
rsync -azvh  /home/tmichel/projects/rbge/PNG_Begonia/All/* ./reads/
