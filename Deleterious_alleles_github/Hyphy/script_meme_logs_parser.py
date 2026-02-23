#!/usr/bin/env python3

import re
import csv
import sys
import os

def extract_meme_table(input_file, output_csv):
    # Use "inexact" header detection
    header_keywords = ["Site", "alpha", "beta-", "p-", "beta+", "p+", "LRT", "p-value"]
    
    table_started = False
    rows = []
    header = header_keywords
    
    with open(input_file, 'r') as infile:
        for line in infile:
            line_strip = line.strip()
            
            if not table_started:
                # Check if all header keywords are present in the line
                if all(keyword in line_strip for keyword in header_keywords):
                    table_started = True
                continue
            else:
                if not line_strip:
                    break  # empty line means end of table

                # Split on any whitespace (space, tab, etc.)
                fields = re.split(r'\s+', line_strip)

                if len(fields) == 8:
                    rows.append(fields)
                else:
                    break  # end of table if line does not match

    if not rows:
        print(f"No table found in {input_file}")
        return
    
    with open(output_csv, 'w', newline='') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(header)
        writer.writerows(rows)
    
    print(f"Table extracted successfully to {output_csv}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_meme_logs_parser.py <input_log_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_csv = os.path.splitext(input_file)[0] + ".csv"
    
    extract_meme_table(input_file, output_csv)




