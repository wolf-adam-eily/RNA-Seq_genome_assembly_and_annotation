#this file contains the code to index the yellow croaker genome and align the fastq reads if being performed on a server
hisat2-build GCF_000972845.1_L_crocea_1.0_genomic.fna L_crocea -p 4
hisat2 -p 4 --dta -x L_crocea -U trimmed_LB2A_SRR1964642.fastq -S trimmed_LB2A_SRR1964642.sam
hisat2 -p 4 --dta -x L_crocea -U trimmed_LB2A_SRR1964643.fastq -S trimmed_LB2A_SRR1964643.sam
hisat2 -p 4 --dta -x L_crocea -U trimmed_LC2A_SRR1964644.fastq -S trimmed_LC2A_SRR1964644.sam
hisat2 -p 4 --dta -x L_crocea -U trimmed_LC2A_SRR1964645.fastq -S trimmed_LC2A_SRR1964645.sam