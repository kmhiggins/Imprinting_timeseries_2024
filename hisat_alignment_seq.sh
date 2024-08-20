#!/bin/bash
#sbatch --array=0-12 /work/LAS/sna-lab/kmh/scripts/hisat_alignment_seq.sh
#SBATCH --time=12:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=6
#SBATCH --cpus-per-task=1 
#SBATCH --mem=120G
#SBATCH --job-name="hisat_seq" 
#SBATCH --mail-user=kaitlinj@iastate.edu   # email address
#SBATCH --mail-type=BEGIN 
#SBATCH --mail-type=END 
#SBATCH --mail-type=FAIL

#Load modules
module load sra-toolkit/2.9.6-ub7kz5h
module load py-cutadapt/1.13-py2-e2j6srt
module load hisat2/2.2.0-5kvb7f2
module load py-htseq/0.11.2-py2-4757mqt

# Read in sample file to use parts
cd /work/LAS/sna-lab/kmh/projects/mRNA_2021/

readarray -t FILES < mRNA_2021_v3.txt
SlurmsMcKenzie=${FILES[$SLURM_ARRAY_TASK_ID]}
IFS=' '
read -ra INFO <<< "$SlurmsMcKenzie"
FILEPATH="$(cut -f 1 <<< $INFO)"
FILE="$(cut -f 2 <<< $INFO)"
SAMPLE="$(cut -f 3 <<< $INFO)"
CROSS="$(cut -f 4 <<<$INFO)"
CROSS_SAMPLE="$(cut -f 5 <<< $INFO)"
GENOME="$(cut -f 6 <<< $INFO)"
#Make needed directories
mkdir -p fastafiles
mkdir -p counts
mkdir -p STAR
mkdir -p fastqc

#merge two runs for each sample
cat ${FILEPATH}1/${FILE}1_R1_001.fastq ${FILEPATH}2/${FILE}2_R1_001.fastq > ${SAMPLE}1.fastq
cat ${FILEPATH}1/${FILE}1_R2_001.fastq ${FILEPATH}2/${FILE}2_R2_001.fastq > ${SAMPLE}2.fastq

cutadapt  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -m 30 -q 10 --quality-base=33 -o trimmed/${SAMPLE}_1_out -p trimmed/${SAMPLE}_2_out ${SAMPLE}1.fastq ${SAMPLE}2.fastq

hisat2 -p 6 -k 20 -S /work/LAS/sna-lab/kmh/projects/mRNA_2021/aligned/sam_files/${CROSS}_aligned.sam -x /work/LAS/sna-lab/kmh/data/htseq_libs/${GENOME}/${GENOME} -1 trimmed/${SAMPLE}_1_out -2 trimmed/${SAMPLE}_2_out

module load samtools
samtools sort -O sam aligned/sam_files/${CROSS}_aligned.sam -o aligned/sam_files/${CROSS}_aligned.sorted.sam

htseq-count -f sam -r pos -s no -t all -i ID -m union -a 0 aligned/sam_files/${CROSS}_aligned.sorted.sam /work/LAS/sna-lab/kmh/data/concat_genomes/${GENOME}_all.sorted.gff3 > counts_unique_${CROSS}.txt
