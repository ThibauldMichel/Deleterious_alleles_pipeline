import json
import csv
import sys
import os

# Check if the user provided the input argument
if len(sys.argv) != 2:
    print("Usage: python3 script_meme_logs_parser.py PATTERN.json")
    sys.exit(1)

# Get the input filename from command-line argument
input_file = sys.argv[1]

# Extract the pattern name (without .json)
basename = os.path.basename(input_file)
pattern_name = os.path.splitext(basename)[0]

# Create output directory if it doesn't exist
output_dir = "./csv_extracted_MEME"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Full output path
output_file = os.path.join(output_dir, pattern_name + ".csv")

# Load JSON file
with open(input_file, "r") as f:
    data = json.load(f)

# Access content
rows = data["MLE"]["content"]["0"]

# Column names
columns = [
    "alpha", "beta-", "p-", "beta+", "p+", "LRT", "p-value",
    "branches_with_selection", "unused", "LogL", "AICc"
]

# Full header with partition and site
header = ["partition", "codon"] + columns

# Prepare data rows
table = []
for idx, row in enumerate(rows):
    site_number = idx + 1
    partition = 0  # single partition for now
    table.append([partition, site_number] + row)

# Write CSV output
with open(output_file, "w") as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(table)

print(f"✅ Successfully parsed '{input_file}' to '{output_file}'")





