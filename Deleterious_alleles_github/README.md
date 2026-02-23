# Conserved Region Inference Pipeline (HyPhy + GERP++)

This repository provides a reproducible **Snakemake pipeline** to detect **conserved genomic regions under selection** by combining:

- **HyPhy** (codon-level evolutionary rate analysis, dN/dS)
- **GERP++** (deep evolutionary conservation, Rejected Substitution scores)

The intersection of both methods highlights sites likely to be functionally important and potentially linked to deleterious alleles.

---

## Overview

- **GERP++** → detects positions with fewer substitutions than expected under neutrality.
- **HyPhy** → detects codons under purifying selection.
- **Intersection (GERP ∩ HyPhy)** → conserved regions likely under strong selection.
- **Optional**: Filter variants by Minor Allele Frequency (MAF), annotate with SnpEff or VEP.

---

## Requirements

Install dependencies manually or with [conda](https://docs.conda.io/).

- [HyPhy](https://github.com/veg/hyphy)
- [GERP++](http://mendel.stanford.edu/SidowLab/downloads/gerp/index.html)
- [bcftools](http://samtools.github.io/bcftools/)
- [samtools](http://www.htslib.org/)
- [seqtk](https://github.com/lh3/seqtk)
- [IQ-TREE](http://www.iqtree.org/)
- [SnpEff](https://pcingola.github.io/SnpEff/)
- [Snakemake](https://snakemake.github.io/)

---

## Configuration

Edit `config/config.yaml` before running:

```yaml
HYPHY_PATH: /path/to/hyphy
GERP_PATH: /path/to/gerp
genes:
  - gene1
  - gene2
samples:
  - PNG1
  - PNG2
```

# Running the Pipeline

Run the workflow with:

```
snakemake --cores 8
```

Outputs will be generated in `results/`.

## Workflow

The pipeline runs the following steps:

1. **HyPhy**
   * Input: `{gene}.msa`, `{gene}.tree`
   * Output: `results/hyphy/{gene}.all_loci.csv`
2. **GERP++**
   * Input: `{gene}.msa`, `{gene}.tree`
   * Output: `results/GERP/{gene}.all.mfa.rates.elems`
3. **ROH pipeline (optional)**
   * Input: `{sample}.vcf`
   * Output: `results/{sample}.all.vcf`
4. **Intersection (HyPhy ∩ GERP)**
   * Input: HyPhy + GERP outputs
   * Output:
     * `results/intersection_GERP_Hyphy/intersection_GERP_HyPhy.bed`
     * `results/intersection_GERP_Hyphy/Genomic_Regions_all_intersections.png`
5. **Extract Variants**
   * Input: VCF + BED
   * Output: `results/bait_variants.vcf`
