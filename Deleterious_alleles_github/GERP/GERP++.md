# GERP++

The main source of information is a github link\!  
[https://www.biostars.org/p/9563600/](https://www.biostars.org/p/9563600/)

But luckily, there is Github repository:  
[https://github.com/tvkent/GERPplusplus](https://github.com/tvkent/GERPplusplus)

## GERP

---

The **Genomic** **Evolutionary Rate Profiling score** (**GERP**) is used to identify and quantify conserved elements in a genome [(Davydov *et al.*, 2010\)](https://www.zotero.org/google-docs/?Trs8kg). Conserved genomic regions are likely to be functionally important, as they have remained unchanged over long periods of evolutionary time. By aligning the genomic regions of multiple related species in a Multiple Sequence Alignment (MSA), we can calculate a rejected substitution score, difference between the number of observed substitutions and expected substitutions from Hardy-Weinberg equilibrium, and this score is the base of GERP. A high positive score indicates that fewer substitutions occurred than expected by chance, implying that the position is highly conserved and likely under **strong selection**. This is used to detect important regions in the genome, such as protein-coding exons or critical regulatory sequences. This score has been used to detect deleterious variants across genomes of 490 accessions of seed genebank to detect deleterious mutational changes in 7 germplasms collections [(Fu, 2023\)](https://www.zotero.org/google-docs/?NdLyep).

## RS score 

---

The **Rejected Substitution (RS) score** quantifies how strongly evolution has **constrained** a given nucleotide position in a multiple sequence alignment of orthologous sequences.  
The term **"rejected substitution"** comes from the **difference between the number of substitutions expected under neutrality** (if the position evolved without constraint) and the **number actually observed** in the alignment.

* **Expected substitutions**: This is the number of substitutions that would be expected to occur at the site if it were evolving neutrally (without selection). It depends on the phylogenetic tree and neutral mutation rates.

* **Observed substitutions**: The actual number of substitutions seen in the alignment.

**RS score \= Rejected Substitution score for each position.**

RS score reflects how many substitutions were "**rejected**" by purifying selection, that is, how much less variable a site is than you'd expect if it were neutral. Hence the name.

The RS score helps us **identify regions of the genome that are under purifying (negative) selection**, places where mutations are being "rejected" by evolution because they would break something important.

Compare observed substitutions with expected neutral substitution rate in an Multiple Sequence Alignment (MSA) of orthologous genomic sequences.

**RS=Expected Substitutions−Observed Substitutions**

| Positive RS Score (e.g., \> 2 or 3\) | Indicates evolutionary constraint, meaning the position is highly conserved and likely functionally important. *It means that expected substitutions \> observed substitutions. There are less substitutions than expected, therefore selection pressure keeps this loci unchanged in a conserved region.* |
| :---- | :---- |
| RS ≈ 0 | Suggests the position evolves neutrally, meaning no strong selection pressure. *The expected substitutions \= observed substitutions. There is no selection pressure, the amount of substitution being not below or above the expected level of substitutions in a neutral evolution region.*   |
| Negative RS Score | Suggests accelerated evolution, possibly due to positive selection or relaxed constraint. *Expected substitutions \< observed substitutions. There are more substitutions than expected, which means this site was under selection pressure, but it has disappeared over time. Mutation is more tolerated than before.  It’s called “relaxed” because the **strength of constraint (selection against mutation) is lower**, not necessarily gone entirely.* |

##  Gerpcol

## ---

Compute RS scores for every position of each alignment.

Gerpcol requires an evolutionary tree and at least one multiple alignment file (in mfa format) to be processed.

## Gerpelem

## ---

Given a rates file as output by gerpcol, gerpelem will find and report a list of elements that appear constrained beyond what is likely to occur by chance. But as repetitive elements fit that description, statistics are used to remove them.

