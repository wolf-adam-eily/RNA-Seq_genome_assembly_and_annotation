#!/bin/bash
#SBATCH --job-name=sam_to_bam_xanadu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --partition=general
#SBATCH --mail-type=END
#SBATCH --mail-user=
#SBATCH --mem=50G
#SBATCH -o sam_to_bam_xanadu_%j.out
#SBATCH -e sam_to_bam_xanadu_%j.err
module load samtools
samtools sort -@ 4 -o sort_trim_LB2A_SRR1964642.bam trimmed_LB2A_SRR1964642.sam
samtools sort -@ 4 -o sort_trim_LB2A_SRR1964643.bam trimmed_LB2A_SRR1964643.sam
samtools sort -@ 4 -o sort_trim_LC2A_SRR1964644.bam trimmed_LC2A_SRR1964644.sam
samtools sort -@ 4 -o sort_trim_LC2A_SRR1964645.bam trimmed_LC2A_SRR1964645.sam
