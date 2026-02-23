#!/bin/bash

#SBATCH --job-name="extract tables"
#SBATCH --export=ALL
#SBATCH --mem=200G
#SBATCH --partition=short





mkdir -p ./csv_results

while read -r prefix; do
    log_file="./logs/${prefix}.log"
    csv_file="./csv_results/${prefix}_meme_results.csv"
    
    # Step 1: Extract the table block (from "| Codon |" to next empty line)
    awk '/^\| Codon \|/{flag=1; next} /^$/{flag=0} flag' "$log_file" > tmp_table.txt
    
    # Step 2: Clean and convert to CSV
    sed -E '
        s/^\|//; s/\|$//;     # Remove leading/trailing |
        s/\|/,/g;             # Replace | with ,
        s/^,|,$//g;           # Remove dangling commas
        s/[[:space:]]+//g;    # Remove extra spaces
        /^$/d;                # Delete empty lines
    ' tmp_table.txt > "$csv_file"
    
    # Check if the CSV has content
    if [[ -s "$csv_file" ]]; then
        echo "Extracted: $csv_file"
    else
        echo "FAILED: No table found in $log_file"
        rm -f "$csv_file"     # Delete empty file
    fi
    
    rm -f tmp_table.txt       # Cleanup
done < mfa_files.txt










