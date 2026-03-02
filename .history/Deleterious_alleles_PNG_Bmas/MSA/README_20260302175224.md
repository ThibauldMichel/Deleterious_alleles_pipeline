# Use VCF file to output MSA individual genes alignments.

## 1. Script 01 preprocessing

We index the VCF reference file, as the previous ROH pipeline does not do it "step 0". 

We are going to use only SNPs to produce the alignments, indels are not use for the phylogenetic reconstruction we are doing. We will keep single-base substitutions SNPs as it does not induce change in sequence length and ambiguity about alignment. SNPs-only data sets capture most variation, avoid alignment errors, and are computationally simple. It is "step 1".
We use the Normalization command of bcftools as it splits multiallelic variantrs in different variants (two lines instead of one) and normalize indels (we don't care, we filtered them out). This is "step 2".

## 2. Script 02 array consensus

The "step 3" of the script is bcftools consensus that produce a fasta file (.fa) countaining the consensus sequence for all the chromosomes of a single individual.

The "step 4" of the script split the consensus sequence of each samples into chromosomes. It make a LOT of fasta files (nber of fasta = nber chromosomes x nber samples). 

## 3. Script 03 build MSA

The "step 5" index the single FASTA files with samtools faidx, then with a homemade script, we build a chromosome file in which every matching sequences from the same locus are stored in a new FASTA file, tagged with the name of the sample. We end up with one MSA file per chromosome.

The "step 6" re-align the MSA files with MAFFT. After this step, check visualy that each MSA alignement files are indeed aligned.
