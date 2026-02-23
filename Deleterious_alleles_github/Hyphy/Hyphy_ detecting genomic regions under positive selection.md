# Hyphy: detecting genomic regions under positive selection

## Detecting regions under positive selection

---

We want to find fitness-critical sites where changes can alter phenotypes or survival. To do so, we will intersect conserved sites (GERP++ score) with sites under positive selection (MEME). The intersection of these regions will provide **critical sites, highly conserved**, that have had beneficial mutations in specific evolution time. 

## Hypothesis testing with HyPhy

---

HyPhy (Hypothesis Testing using Phylogenies). Use of Hyphy for evaluating selection pressures is given p. 453 of [(Salemi, Vandamme and Lemey, 2009\)](https://www.zotero.org/google-docs/?5IoHSM)

HyPhy is a set of softwares implementing **statistical tests** to compare **competing evolutionary hypotheses** about selection.

Why testing hypotheses when talking about selection pressure?

Because HyPhy detects positive selection by testing statistical hypotheses about how genes evolve across a phylogeny. It compares models **with and without** selection to see which better fits your data.  
When we run MEME or BUSTED, you're not just "searching for selection", you're formally **testing whether the data support a selection hypothesis**, and getting statistical significance (like p-values or posterior probabilities) for your findings.

| Is a gene evolving under positive selection?We can phrase this as two hypotheses: Null hypothesis (H0): The gene is evolving neutrally or under purifying selection (ω ≤ 1\) Alternative hypothesis (H1): The gene or specific sites in the gene are under positive selection (ω \> 1\) |
| :---- |

HyPhy uses **likelihood ratio tests (LRTs)** to compare how well each model explains the observed sequence data. If the data fits the alternative model significantly better, you can reject the null hypothesis, providing evidence for positive selection.

## Omega, the (=dN/dS)  ratio

---

A common signal of positive selection is an excess of **nonsynonymous substitutions** (those that change the protein) compared to **synonymous substitutions** (those that don’t).

| It is measured by the (=dN/dS) ratio (ω, omega):ω \> 1 suggests positive selectionω \= 1 neutral evolutionω \< 1 purifying selection |
| :---- |

### **HyPhy's models for detecting selection**

HyPhy includes several well-known models for detecting different types of selection:

* **SLAC, FEL, FUBAR**: Detect selection at individual codon sites across all branches

* **MEME**: Detects **episodic positive selection** at individual sites (positive selection only in some branches)

* **aBSREL, BUSTED**: Detect **branch-specific** or **gene-wide** selection

All of these use **model comparison and hypothesis testing** at their core.

## Considerations for timescale

---

GERP++ score indicates long-term genomic regions conservation, where MEME detects short-term selection. Time scales differ.

MEME looks for **bursts of selection at specific codon sites**, but **only on some branches** of the phylogeny. It doesn’t assume the site is under selection across all lineages — only that **ω \> 1 on at least one branch**.  
Short-term selection means selection that occurred **in a subset of lineages during specific evolutionary events**, not necessarily across deep evolutionary time.

**MEME detects “when selection mattered,” not “how long it lasted.”**  
It’s a snapshot, was there **evidence of ω \> 1** on a specific branch at a site? That’s all. It doesn't require the selection to be ongoing or sustained.

## References

---

[Salemi, M., Vandamme, A.-M. and Lemey, P. (eds) (2009) *The phylogenetic handbook: a practical approach to phylogenetic analysis and hypothesis testing*. 2nd ed. Cambridge: Cambridge University Press. Available at: https://doi.org/10.1017/CBO9780511819049.](https://www.zotero.org/google-docs/?JXLCuP)