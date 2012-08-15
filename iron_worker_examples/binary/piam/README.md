PIAM

Pair-wise Interaction-based Association Mapping

Usage

1. Grab GSL library and put into the current directory in subdirectory gsl/
2. Fill out iron.json credentials
3. ironworker upload piam
4. ironworker queue piam

That's it!



Background

The multi-thread/parallel PIAM program uses fast methods to search for gene-gene interactions for common diseases from case-control-designed genome-wide SNP data of genome-wide association studies (GWAS). The programs are easy to use; however, before practice on real data, it is recommended to fully understand the principles which are not difficult for most statistical geneticists.

PIAM uses the following strategy: First step, single-locus tests are performed, and then all SNPs are divided by a family-wise significant single-locus p-value threshold, into SNP subset A (significant) and subset B (non-significant). Second step, the pair-wise epistatic search, conditional search, and simultaneous search are performed within A, between A and B, and within B, respectively; the marginal effects of SNPs in subset A were “removed” in the two-locus tests, to avoid too many significant interactions merely caused by a few SNPs in subset A. Bonferroni correction is used for N multiple tests, in which N is the number of tests for all three search situations. PIAM use the likelihood ratio tests based on logistic regression models, and the statistics for the conditional search and simultaneous search are calculated with contingency tables (which are collected in a fast manner) to save computational time. For more details, please refer to “Brief_Method.ppt” or the reference article.

We implemented the two steps mentioned above into two separate programs, one program for the single-locus tests, and the other multi-thread/parallel program for two-locus tests. The users could flexibly modify the parameters for the searches, even for some special use; However, please be aware of what the parameters are used for, to avoid misuse of these programs. As a search tool, PIAM gives raw results for interactions which do not always represent true associations, and please read the reference article for details on the subsequent filtering/analysis of the results.


Article discussing PIAM

http://www.plosgenetics.org/article/info:doi/10.1371/journal.pgen.1001338
