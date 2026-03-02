# Methodology 	 	

## **Deleterious alleles frequencies**

The concept of dominance is intrinsically related to genetic load and to the frequency of deleterious variants [(Henn *et al.*, 2015\)](https://www.zotero.org/google-docs/?1SMRTV). A consequence of this impact is the inverse relationship between dominance and severity of mutations [(Agrawal and Whitlock, 2011\)](https://www.zotero.org/google-docs/?CKg6rO). The severity of the deleterious mutation is inversely proportional to *h*. Why? Deleterious variants with large-effects on phenotype have been purged by purifying selection, and are found in low frequency.

## **Identifying conserved regions with substitution rates**

The **Genomic** **Evolutionary Rate Profiling score** (**GERP**) is used to identify and quantify conserved elements in a genome [(Davydov *et al.*, 2010\)](https://www.zotero.org/google-docs/?Trs8kg). Conserved genomic regions are likely to be functionally important, as they have remained unchanged over long periods of evolutionary time. By aligning the genomic regions of multiple related species in a Multiple Sequence Alignment (MSA), we can calculate a rejected substitution score, difference between the number of observed substitutions and expected substitutions from Hardy-Weinberg equilibrium, and this score is the base of GERP. A high positive score indicates that fewer substitutions occurred than expected by chance, implying that the position is highly conserved and likely under **strong selection**. This is used to detect important regions in the genome, such as protein-coding exons or critical regulatory sequences. This score has been used to detect deleterious variants across genomes of 490 accessions of seed genebank to detect deleterious mutational changes in 7 germplasms collections [(Fu, 2023\)](https://www.zotero.org/google-docs/?NdLyep).

The conda link of gerp is accessible [here](https://bioconda.github.io/recipes/gerp/README.html). 

**The Rejected Substitution (RS)** score for each position describes the degree of conservation by selection pressure on a specific locus. It therefore indicates an important conserved region maintained. 

## **Identifying conserved regions with phylogenetic evolutionary rates**

**Baseml** is a tool of the Phylogenetic Analysis by Maximum Likelihood (PAML) package [(Yang, 2007\)](https://www.zotero.org/google-docs/?6vie3R). It is used to estimate the evolutionary rates at different sites or along different branches of a phylogenetic tree based on a multiple sequence alignment. It provides estimates of the substitution rates at each site, which can vary depending on the evolutionary model used. May help to identify different parts of the genome under positive selection.

Polymorphism in these ancestral alleles is indicative of a possible deleterious mutation with high-effect, and might therefore be responsible for genetic load [(Long *et al.*, 2023\)](https://www.zotero.org/google-docs/?toVHdE).

Baseml is a bit outdated, and an alternative, **Hyphy**, is described p. 453 of [(Salemi, Vandamme and Lemey, 2009\)](https://www.zotero.org/google-docs/?5IoHSM).

We can estimate the **evolutionary rate** of nonsynonymous/synonymous rate ratio (=dN/dS) with **Hyphy**, a package that detects part of the genome under positive selection.

Intersection conserved regions and sites under selection

The highly conserved sites maintained by selection are detected using the Rejected 

## **Filtering the results by Minor Allele Frequencies**

The conserved regions selected with intersection of GERP and baseml score are highly conserved, a variation in these sites is potentially highly deleterious. A method to ensure that the allele selected has a low occurrence and likely to be deleterious is to consider a very large set of haplotypes and select loci with a low Minor Allele Frequency (MAF). This method has been used to detect deleterious alleles in Cassava using a specific set of data called the Cassava HapMap. This data set included 241 Cassava accessions gathered in order to build an haplotype map [(Long *et al.*, 2023\)](https://www.zotero.org/google-docs/?IW5sVI). This project has isolated 28 millions variants and gives access to a large range of different alleles across populations, and only the sites with a MAF lower than 20% were selected as potential deleterious alleles [(Ramu *et al.*, 2016\)](https://www.zotero.org/google-docs/?FbpT1t).

## **Estimate the quantitative impact of deleterious mutations**

The first step to understand the impact of potential deleterious mutations is to annotate the genomes at selected sites with tools such as Ensembl-Variant Effect Predictor  [(McLaren, 2016\)](https://www.zotero.org/google-docs/?2Lo6AH), which can even detect variants associated with loss of function (LOF).

To estimate the impact of each non-synonymous mutation in the sites identified as potentially deleterious, we can use the **Sorting Intolerant from Tolerant** (**SIFT**) algorithm to predict the effect of coding variants on protein function [(Sim *et al.*, 2012\)](https://www.zotero.org/google-docs/?e6VRyo). RandomForest prediction model: A machine learning technique used for classification and regression that can handle complex interactions between variables. With the previous methods, we were using methods to tell if sites were deleterious or not. With the RandomForest model, we try to quantify the impact of each nonsynonymous mutation on phenotype [(Long *et al.*, 2023\)](https://www.zotero.org/google-docs/?Rlpdmb). We take conserved sites by baseml filtering. They use a RandomForest model to help determine which nonsynonymous mutations are functionally significant. We take the SIFT score from each of these sites to predict deleterious effects. UniRep deep learning technique can predict change in protein structure.

## **Genomic variant annotations and functional effect prediction**

SnpEff and SnpSift

[https://pcingola.github.io/SnpEff/](https://pcingola.github.io/SnpEff/)

## **Litterature**

[Agrawal, A.F. and Whitlock, M.C. (2011) ‘Inferences about the distribution of dominance drawn from yeast gene knockout data’, *Genetics*, 187(2), pp. 553–566. Available at: https://doi.org/10.1534/genetics.110.124560.](https://www.zotero.org/google-docs/?qzNJyE)

[Davydov, E.V. *et al.* (2010) ‘Identifying a high fraction of the human genome to be under selective constraint using GERP++’, *PLoS computational biology*, 6(12), p. e1001025. Available at: https://doi.org/10.1371/journal.pcbi.1001025.](https://www.zotero.org/google-docs/?qzNJyE)

[Fu, Y.-B. (2023) ‘Deleterious and Adaptive Mutations in Plant Germplasm Conserved Ex Situ’.](https://www.zotero.org/google-docs/?qzNJyE)

[Henn, B.M. *et al.* (2015) ‘Estimating the mutation load in human genomes’, *Nature Reviews Genetics*, 16(6), pp. 333–343. Available at: https://doi.org/10.1038/nrg3931.](https://www.zotero.org/google-docs/?qzNJyE)

[Long, E.M. *et al.* (2023) ‘Utilizing evolutionary conservation to detect deleterious mutations and improve genomic prediction in cassava’, *Frontiers in Plant Science*, 13, p. 1041925\. Available at: https://doi.org/10.3389/fpls.2022.1041925.](https://www.zotero.org/google-docs/?qzNJyE)

[McLaren, W. (2016) ‘The Ensembl Variant Effect Predictor’.](https://www.zotero.org/google-docs/?qzNJyE)

[Ramu, P. *et al.* (2016) ‘Cassava HapMap: Masking deleterious mutations in a clonal crop species’. Available at: https://doi.org/10.1101/077123.](https://www.zotero.org/google-docs/?qzNJyE)

[Sim, N.-L. *et al.* (2012) ‘SIFT web server: predicting effects of amino acid substitutions on proteins’, *Nucleic Acids Research*, 40(W1), pp. W452–W457. Available at: https://doi.org/10.1093/nar/gks539.](https://www.zotero.org/google-docs/?qzNJyE)

[Yang, Z. (2007) ‘PAML 4: phylogenetic analysis by maximum likelihood’, *Molecular Biology and Evolution*, 24(8), pp. 1586–1591. Available at: https://doi.org/10.1093/molbev/msm088.](https://www.zotero.org/google-docs/?qzNJyE)