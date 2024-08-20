# Imprinting_timeseries_2024
Scripts and files associated with the timepoint imprinting analysis explained in Higgins et al., 2024 "Conservation of imprinted expression across genotypes is correlated with consistency of imprinting across endosperm development in maize"

All R scripts have been modified so that file paths read as /path/to/file/[filename] and will need to be modified prior to running scripts 

Paired-end cDNA libraries were prepared using the NEBNext Ultra II Directional RNA kit (cat #E7760S). Samples were then sequenced on the Illumina NovaSeq 6000 using 150 paired-end sequencing at the Iowa State DNA facility, resulting in an average of 45 million reads per sample. Sequence reads were trimmed using cutadapt (parameters -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -m 30 -q 10 --quality-base=33) then aligned to the concatenated parental genome assemblies. Concatenated parental genome assemblies were created by appending the W22-NRGene assembled chromosomes 1-10 (Springer et al. 2018) to the B73v5 assembled chromosomes 1-10 (Woodhouse et al. 2021) to create a single fasta file. The time series samples were additionally aligned in parallel with aligning to the individual B73v5 genome using hisat2  (parameters -p 6 -k 20). Counts were determined through htseq-count (Anders et al. 2014) (parameters -f bam -r pos -s no -t all -i sequence_feature -m union -a 0) using a gene annotation file created by concatenating the B73v5 and W22 annotation files. The counts were then normalized to reads per million (rpm). Differential expression was determined using R packages, and only features with |>1| Log2FoldChange along with an FDR padj < .05 were called as differentially expressed.
Full details on methods can be found in the soon-to-be-linked paper

### Summary of scripts and files they are dependent on:
kmeans_rpm.Rmd is the script used for normalizing raw read counts to be between zero and one based on the max value at any time point. This script additionally evaluates all expressed genes for differential expression and summarizes that data. 
Files needed to run:
combined_counts_B73mat_toB73.txt 
combined_counts_W22mat_toB73.txt 
B73_GO.out


kmean.Rmd is a script for clustering through kmeans, and plotting expression across time points developed by Vital Nyabashi, with an added GO analysis of each cluster developed by Kaitlin Higgins
Files needed to run:
kmeans_rownormalized_zero_to_one_B73.txt
kmeans_rownormalized_zero_to_one_W22.txt
B73_GO.out

Imprinting_mRNA_forGH.Rmd is a script analyzing imprinted expression across eight maize genotypes when reciprocally crossed with B73. This script includes older data as well as newly generated data for imprinting analysis. Because of this there are two repetitions of B73xOh43. B73xOh43 refers to the samples collected in 2020 by the Anderson Lab at Iowa State University, while B73xOh43_MN refers to samples collected in 2013 by the Springer lab at University of Minnesota. 
Files needed to run:
combined_NAM_gene_counts.txt
combined_NAM_counts_genes.txt
new_NAM.tsv

Timepoint_script_forGH.Rmd is the main time series analysis script utilizing both the time series analysis as well as maternal preference calculated from Imprinting_mRNA_forGH 
Files needed to run:
combined_counts_W22xB73_recips_timeseries.txt
sample.info.txt
mat_pref_NAM.txt
new_NAM.tsv
Endosperm_pref_B73.csv
W22_endo_pref_call.txt <- from Higgins et. al., 2024 "MDR1 DNA glycosylase regulates the expression of genomically imprinted genes and helitrons"
B73_DE.out2
W22_DE.out2
zein_gene_key_listed.txt
MEGs_in_mdr1.txt <- from Higgins et. al., 2024 "MDR1 DNA glycosylase regulates the expression of genomically imprinted genes and helitrons"

The new_NAM.tsv file was created using format_geneIDs.pl on the file MaizeGDB_maize_pangene_2020_08.tsv to pull only the genomes utilized in this study and concatenate gene IDs. We then pared this down to single copy genes for use in our analysis. 
