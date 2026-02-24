#!/bin/bash

#SBATCH --job-name="snakemake"
#SBATCH --export=ALL
#SBATCH --mem=150G
#SBATCH --partition=medium


#source activate snakemake
#source activate snakemake

source /mnt/apps/users/tmichel/conda/etc/profile.d/conda.sh

conda activate snakemake_env

#conda install -c bioconda snakemake-wrapper-utils



snakemake --version





snakemake --cores all --use-conda --conda-frontend conda --latency-wait 60 --rerun-incomplete  
#--unlock :
