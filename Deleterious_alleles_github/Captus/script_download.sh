
# Download data from cropdiversity:
#

rsync -azvh --exclude 01_clean_reads --exclude 02_assemblies --exclude 03_extractions --exclude 04_alignments  tmichel@gruffalo.cropdiversity.ac.uk:/home/tmichel/scratch/CAPTUS/CAPTUS-PNG/* ./



#rsync -azvh  tmichel@gruffalo.cropdiversity.ac.uk:~/scratch/CAPTUS/CAPTUS-PNG/04_alignments/03_trimmed/* ./04_alignments/03_trimmed/
