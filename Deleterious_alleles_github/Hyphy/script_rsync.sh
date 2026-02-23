
rsync -azvh  tmichel@gruffalo.cropdiversity.ac.uk:/home/tmichel/scratch/hyphy/gene_trees/*.treefile ./gene_trees/



rsync -azvh --exclude gene_trees --exclude raw_msa  tmichel@gruffalo.cropdiversity.ac.uk:~/scratch/hyphy/* ./


rsync -azvh --exclude gene_trees --exclude raw_msa  tmichel@gruffalo.cropdiversity.ac.uk:~/scratch/hyphy/output_meme ./
