#!/bin/bash
#sbatch --array=0-25 /work/LAS/sna-lab/kmh/scripts/timepoint_alignment.sh
#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=4   # number of nodes
#SBATCH --ntasks-per-node=6
#SBATCH --cpus-per-task=1
#SBATCH --mem=200G
#SBATCH --partition=nova
#SBATCH --job-name="hisat_seq"
#SBATCH --mail-user=kaitlinj@iastate.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#Load modules
module load tbx-rnaseq
module load subread

# Read in sample file to use parts
cd /work/LAS/sna-lab/kmh/projects/timepoint/

readarray -t FILES < timepoint_index.txt
SlurmsMcKenzie=${FILES[$SLURM_ARRAY_TASK_ID]}
IFS=' '
read -ra INFO <<< "$SlurmsMcKenzie"
FILEPATH="$(cut -f 1 <<< $INFO)"
FILE="$(cut -f 2 <<< $INFO)"
SAMPLE="$(cut -f 3 <<< $INFO)"

#Make needed directories
mkdir -p trimmed
mkdir -p counts
mkdir -p aligned
mkdir -p aligned/sam_files

#rename files
#cat ${FILEPATH}1/${FILE}_L001_R1_001.fastq.gz  ${FILEPATH}2/${FILE}_L002_R1_001.fastq.gz> ${SAMPLE}_1.fastq
#cat ${FILEPATH}1/${FILE}_L001_R2_001.fastq.gz  ${FILEPATH}2/${FILE}_L002_R2_001.fastq.gz> ${SAMPLE}_2.fastq

#tbx-rnaseq cutadapt  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -m 30 -q 10 --quality-base=33 -o trimmed/${SAMPLE}_1_out.fastq -p trimmed/${SAMPLE}_2_out.fastq ${SAMPLE}_1.fastq ${SAMPLE}_2.fastq

tbx-rnaseq hisat2 -p 6 -k 20 -S /work/LAS/sna-lab/kmh/projects/timepoint/aligned/sam_files/${SAMPLE}_aligned.sam -x /work/LAS/sna-lab/kmh/data/htseq_libs/W22xB73/W22xB73 -1 trimmed/${SAMPLE}_1_out.fastq -2 trimmed/${SAMPLE}_2_out.fastq

#module load samtools
samtools sort -O sam aligned/sam_files/${SAMPLE}_aligned.sam -o aligned/sam_files/${SAMPLE}_aligned.sorted.sam
samtools view -S -b aligned/sam_files/${SAMPLE}_aligned.sorted.sam > aligned/sam_files/${SAMPLE}_aligned.sorted.bam
samtools index aligned/sam_files/${SAMPLE}_aligned.sorted.bam

#tbx-rnaseq htseq-count -f bam -r pos -s no -t gene -i ID -m union -a 0 aligned/sam_files/${SAMPLE}_aligned.sorted.bam /work/LAS/sna-lab/kmh/data/concat_genomes/W22xB73_genes.sorted.gff3 > counts_unique_${SAMPLE}.txt

featureCounts -p -G /work/LAS/sna-lab/kmh/data/concat_genomes/W22xB73.fa -t gene -g ID -a /work/LAS/sna-lab/kmh/data/concat_genomes/W22xB73_genes.sorted.gff3 -o ${SAMPLE}.counts.txt /work/LAS/sna-lab/kmh/projects/timepoint/aligned/sam_files/${SAMPLE}_aligned.sorted.bam


#rm ${SAMPLE}_?.fastq
#rm aligned/sam_files/${SAMPLE}_aligned*sam
