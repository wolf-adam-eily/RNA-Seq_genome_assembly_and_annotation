# RNA-Seq_genome_assembly_and_annotation
This repository is a usable, publicly available genome annotation and assembly tutorial.
This tutorial assumes the user is using a Linux system (or Ubuntu 17.0.1 or higher).

<div id="toc_container">
<p class="toc_title">Contents</p>
<ul class="toc_list">
<li><a href="#First_Point_Header">1 Overview and programs install</>
<li><a href="#Second_Point_Header">2 Accessing the data using sra-toolkit</a></li>
<li><a href="#Third_Point_Header">3 Quality control using sickle</a></li>
<li><a href="#Fourth_Point_Header">4 Aligning reads to a genome using hisat2</a></li>
<li><a href="#Fifth_Point_Header">5 Generating total read counts from alignment using htseq-count</a></li>
<li><a href="#Sixth_Point_Header">6 Pairwise differential expression with counts in R with DESeq2</a></li>
  <li><a href="#Citation"> Citations</a><li>
</ul>
</div>

<h2 id="First_Point_Header">Overview and programs install</h2>
Marine RNA-Seq
In this tutorial we will be analyzing 2 liver samples from the large yellow croaker (Larimichthys crocea) from the NCBI BioProject (https://www.ncbi.nlm.nih.gov/bioproject/280841) <br>
Experimental Design: <br>

Liver mRNA profiles large yellow croaker (Larimichthys crocea) species are sampled during various conditions namely, control group (LB2A), thermal stress group (LC2A), cold stress group (LA2A) and 21-day fasting group (LF1A) were generated by RNA-seq, using Illumina HiSeq 2000. <br>

We will use the control group (LB2A) and the thermal stress group (LC2A)j

The workflow may be cloned using the terminal command:<br>
<pre style="color: silver; background: black;">$git clone https://github.com/wolf-adam-eily/RNA-Seq_genome_assembly_and_annotation.git<br>
$cd RNA-Seq_genome_assembly_and_annotation<br>
$ls  </pre><br>

After cloning the repository but before beginning the tutorial, it is recommended the command (in the cloned folder): <br>
<pre style="color: silver; background: black;">sh -e programs_installation<br>
sh -e r_3.4.3_install<br>
sudo Rscript r_packages_install </pre> <br>
is run to install <i><b>all</b></i> of the needed software and tools for this tutorial (if an absolute directory error occurs, edit the script to change "~/R-3.4.3" to "/home/(insert_user_name)/R-3.4.3").
<h2 id="Second_Point_Header">Accessing the data using sra-toolkit </h2>

The data may be accessed at the following web page: <br>
https://www.ncbi.nlm.nih.gov/bioproject/280841

LF1A : SRR1964648, SRR1964649
LF2A : SRR1964647, SRR1964646
LB2A : SRR1964642, SRR1964643
LC2A : SRR1964644, SRR1964645<br>
and downloaded with: <br>
<pre style="color: silver; background: black;">fastq-dump SRR1964642<br>
fastq-dump SRR1964643</pre><br>

Repeat fastq-dump for SRR1964644 and SRR1964645 samples, or alternatively run either of the following commands (change directory to the RNA-Seq_genome_assembly_and_annotation folder first): <br>

<pre style="color: silver; background: black;">sh -e fastqdump_server</pre><br>
or<br>
<pre style="color: silver; background: black;">sh -e fastqdump_and_trim_personal_computer</pre><br>

The first command will simply download the four fastq files to your server. If proceeding through this tutorial on a personal computer or laptop without access to a server, run the second command. This command will combine the fastq-dump with the next step, quality control, downloading a fastq file, trimming that file, and the removing the untrimmed file. This is recommended if disk space is an issue (the four files combined consume about 75GB of disk space).<br>
Once download is completed, the files were renamed according to the samples for easy identification. If the first command was run, you should see the following files in your folder: <br>
<pre style="color: silver; background: black;">|-- LB2A_SRR1964642.fastq<br>
|-- LB2A_SRR1964643.fastq<br>
|-- LC2A_SRR1964644.fastq<br>
|-- LC2A_SRR1964645.fastq</pre><br>

<h2 id="Third_Point_Header">Quality control using sickle</h2>

Sickle performs quality control on illumina paired-end and single-end short read data. The following command can be applied to each of the four read fastq files:<br>
<pre style="color: silver; background: black;">sickle se -f LB2A_SRR1964642.fastq -t sanger -o trimmed_LB2A_SRR1964642.fastq -q 30 -l 50</pre><br>

 The options we use;<br>
<pre style="color: silver; background: black;">Options:<br> 
se    Single end reads<br>
-f    input file name<br>
-o    output file name<br>
-q    scan the read with the sliding window, cutting when the average quality per base drops below 30<br> 
-l    Removes any reads shorter than 50</pre><br>
This can be repeated for all four files (if the fastq_dump_server option was exercised, if the fastq_dump_personal_computer option was used then this step has already been completed) by running the shell script:<br>
<pre style="color: silver; background: black;">sh -e fastq_trimming_server</pre><br>
 
Following the sickle run, the resulting file structure will look as follows:<br>
<pre style="color: silver; background: black;">
|-- trimmed_LB2A_SRR1964642.fastq<br>
|-- trimmed_LB2A_SRR1964643.fastq<br>
|-- trimmed_LC2A_SRR1964644.fastq<br>
|-- trimmed_LC2A_SRR1964645.fastq</pre><br>
Examine the .out file generated during the run.  It will provide a summary of the quality control process.<br>
<pre style="color: silver; background: black;">Input Reads: 26424138 Surviving: 21799606 (82.50%) Dropped: 4624532 (17.50%)</pre>

<h2 id="Fourth_Point_Header">Aligning reads to a genome using hisat2</h2>
Building an Index<br>
HISAT2 is a fast and sensitive aligner for mapping next generation sequencing reads against a reference genome.<br>

In order to map the reads to a reference genome, first you need to download the reference genome, and make a index file. We will be downloading the reference genome (https://www.ncbi.nlm.nih.gov/genome/12197) from the ncbi database, using the wget command.<br>
<pre style="color: silver; background: black;">wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/972/845/GCF_000972845.1_L_crocea_1.0/GCF_000972845.1_L_crocea_1.0_genomic.fna.gz</pre><br>
If you feel to be prudent, you can install the genomic, transcriptomic, and proteomic fastas (yes, all will be used in this tutorial, it is advised you download them now) with the command:<br>
<pre style="color: silver; background: black;">sh -e genomic_and_protein_downloads</pre><br>
We will use hisat2-build package in the software to make a HISAT index file for the genome. It will create a set of files with the suffix .ht2, these files together build the index, this is all you need to align the reads to the reference genome (this command is included in the genome_indexing_and_alignment* files, so it is not necessary to run now).<br>
<pre style="color: silver; background: black;">hisat2-build -p 4 GCF_000972845.1_L_crocea_1.0_genomic.fna L_crocea<br>

Usage: hisat2-build [options] <reference_in> <bt2_index_base><br>
reference_in                comma-separated list of files with ref sequences<br>
hisat2_index_base           write ht2 data to files with this dir/basename<br>
<br>
Options:<br>
    -p                      number of threads</pre><br>

After running the script, the following files will be generated as part of the index.  To refer to the index for  mapping the reads in the next step, you will use the file prefix, which in this case is: L_crocea<br>
<pre style="color: silver; background: black;">|-- GCF_000972845.1_L_crocea_1.0_genomic.fna<br>
|-- hisat2_index.sh<br>
|-- L_crocea.1.ht2<br>
|-- L_crocea.2.ht2<br>
|-- L_crocea.3.ht2<br>
|-- L_crocea.4.ht2<br>
|-- L_crocea.5.ht2<br>
|-- L_crocea.6.ht2<br>
|-- L_crocea.7.ht2<br>
|-- L_crocea.8.ht2</pre><br>

Aligning the reads using HISAT2<br>
Once we have created the index, the next step is to align the reads using the index we created. To do this we will be using hisat2 program. The program will give the output in SAM format, which can be used my various programs.<br>
<pre style="color: silver; background: black;">hisat2 -p 4 --dta -x ../index/L_crocea -q ../quality_control/trim_LB2A_SRR1964642.fastq -S trim_LB2A_SRR1964642.sam<br>
Usage: hisat2 [options]* -x <ht2-idx>  [-S <sam>]<br>
-x <ht2-idx>        path to the Index-filename-prefix (minus trailing .X.ht2) <br>
Options:<br>
-q                  query input files are FASTQ .fq/.fastq (default)<br>
-p                  number threads<br>
--dta               reports alignments tailored for transcript assemblers</pre><br>

[]The above must be repeated for all the files. You may run:<br>
<pre style="color: silver; background: black;">sh -e genome_indexing_and_alignment_server</pre><br>
or<br>
<pre style="color: silver; background: black;">sh -e genome_indexing_and_alignment_personal_computer</pre><br>

to process all four files appropriate for your setup.<br>

Once the mapping have been completed, the file structure is as follows:<br>
<pre style="color: silver; background: black;">
|-- mapping.sh<br>
|-- trim_LB2A_SRR1964642.sam<br>
|-- trim_LB2A_SRR1964643.sam<br>
|-- trim_LC2A_SRR1964644.sam<br>
|-- trim_LC2A_SRR1964645.sam</pre><br>

When HISAT2 completes its run, it will summarize each of it’s alignments, and it is written to the standard error file, which can be find in the same folder once the run is completed.<br>

<pre style="color: silver; background: black;">
21799606 reads; of these:<br>
  21799606 (100.00%) were unpaired; of these:<br>
    1678851 (7.70%) aligned 0 times<br>
    15828295 (72.61%) aligned exactly 1 time<br>
    4292460 (19.69%) aligned >1 times<br>
92.30% overall alignment rate</pre><br>

The sam file then need to be converted in to bam format:<br>
<pre style="color: silver; background: black;">samtools view -@ 4 -uhS trim_LB2A_SRR1964642.sam | samtools sort -@ 4 - sort_trim_LB2A_SRR1964642<br>
 Usage: samtools [command] [options] in.sam<br>
Command:<br>
view     prints all alignments in the specified input alignment file (in SAM, BAM, or CRAM format) to standard output in SAM format <br>

Options:<br>
-h      Include the header in the output<br.
-S      Indicate the input was in SAM format<br>
-u      Output uncompressed BAM. This option saves time spent on compression/decompression and is thus preferred when the output is piped to another samtools command<br>
-@      Number of processors<br>

Usage: samtools [command] [-o out.bam]<br>
Command:<br>
sort    Sort alignments by leftmost coordinates<br>

-o      Write the final sorted output to FILE, rather than to standard output.</pre><br>

All samples may be run by executing the following command:<br>
<pre style="color: silver; background: black;">sh -e sam_to_bam_server</pre><br>
or
<pre style="color: silver; background: black;">sh -e sam_to_bam_personal_computer</pre><br>

appropriate for your set-up.<br>

Once the conversion is done you will have the following files in the directory.<br>
<pre style="color: silver; background: black;">|-- sort_trim_LB2A_SRR1964642.bam<br>
|-- sort_trim_LB2A_SRR1964643.bam<br>
|-- sort_trim_LC2A_SRR1964644.bam<br>
|-- sort_trim_LC2A_SRR1964645.bam</pre><br>

<h2 id="Fifth_Point_Header">Generating total read counts from alignent using htseq-count</h2>
Now we will be using the htseq-count program to count the reads which is mapping to the genome.<br>
<pre style="color: silver; background: black;">htseq-count -s no -r pos -t gene -i Dbxref -f bam ../mapping/sort_trim_LB2A_SRR1964642.bam GCF_000972845.1_L_crocea_1.0_genomic.gff > LB2A_SRR1964642.counts<br>
Usage: htseq-count [options] alignment_file gff_file</pre><br>

This script takes an alignment file in SAM/BAM format and a feature file in
GFF format and calculates for each feature the number of reads mapping to it.
See http://www-huber.embl.de/users/anders/HTSeq/doc/count.html for details.<br>
<pre style="color: silver; background: black;">Options:<br>
  -f SAMTYPE, --format=SAMTYPE<br>
                        type of  data, either 'sam' or 'bam'<br>
                        (default: sam)<br>
  -r ORDER, --order=ORDER<br>
                        'pos' or 'name'. Sorting order of<br>
                        (default: name). Paired-end sequencing data must be<br>
                        sorted either by position or by read name, and the<br>
                        sorting order must be specified. Ignored for single-<br>
                        end data.
  -s STRANDED, --stranded=STRANDED<br>
                        whether the data is from a strand-specific assay.<br>
                        Specify 'yes', 'no', or 'reverse' (default: yes).<br>
                        'reverse' means 'yes' with reversed strand<br>
                        interpretation<br>
  -t FEATURETYPE, --type=FEATURETYPE<br>
                        feature type (3rd column in GFF file) to be used, all<br>
                        features of other type are ignored (default, suitable<br>
                        for Ensembl GTF files: exon)<br>
  -i IDATTR, --idattr=IDATTR<br>
                        GFF attribute to be used as feature ID (default,
                        suitable for Ensembl GTF files: gene_id)</pre><br>

 
The above command should be repeated for all other BAM files as well. You can process all the BAM files with the command:<br>
<pre style="color: silver; background: black;">sh -e htseq_count_server</pre><br>
or<br>
<pre style="color: silver; background: black;">sh -e htseq_count_personal_computer</pre><br>
appropriate for your set-up.<br>
Once all the bam files have been counted, we will be having the following files in the directory.<br
<pre style="color: silver; background: black;">|-- sort_trim_LB2A_SRR1964642.counts<br>
|-- sort_trim_LB2A_SRR1964643.counts<br>
|-- sort_trim_LC2A_SRR1964644.counts<br>
|-- sort_trim_LC2A_SRR1964645.counts</pre><br>

<h2 id="Sixth_Point_Header">Pairwise differential expression with counts in R using DESeq2</h2>
To identify differentially expressed genes, we will transfer the count files generated by HTSeq onto our local machine. We will the DESeq package within Bioconductor in R to process to provide normalization and statistical analysis of differences among our two sample groups. This R code can be run with the following command:<br>
<pre style="color: silver; background: black;">Rscript diff_expression_r_script</pre><br>

diff_expression_r_script contains explanations for all code. It is recommended the user study and attempt the code on one's own before moving onward. The resulting files are located in the directory.

<h2 id="Citation">Citations</h2>

Anders, Simon, Paul Theodor Pyl, and Wolfgang Huber. “HTSeq—a Python Framework to Work with High-Throughput Sequencing Data.” Bioinformatics 31.2 (2015): 166–169. PMC. Web. 8 Mar. 2018.

E. Neuwirth, RColorBrewer https://cran.r-project.org/web/packages/RColorBrewer/index.html

Gentleman R, Carey V, Huber W and Hahne F (2017). genefilter: genefilter: methods for filtering genes from high-throughput experiments. R package version 1.60.0. 

Gregory R. Warnes, Ben Bolker, Lodewijk Bonebakker, Robert Gentleman, Wolfgang Huber Andy Liaw, Thomas Lumley, Martin Maechler, Arni Magnusson, Steffen Moeller, Marc Schwartz, Bill Venables, gplots https://cran.r-project.org/web/packages/gplots/index.html

H. Wickham. ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York, 2009. 

Joshi NA, Fass JN. (2011). Sickle: A sliding-window, adaptive, quality-based trimming tool for FastQ files 
(Version 1.33) [Software].  Available at https://github.com/najoshi/sickle.

Leinonen, Rasko, Hideaki Sugawara, and Martin on behalf of the International Nucleotide Sequence Database Collaboration. “The Sequence Read Archive.” Nucleic Acids Research 39.Database issue (2011): D19–D21. PMC. Web. 8 Mar. 2018.

Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R, and 1000 Genome Project Data Processing Subgroup, The Sequence alignment/map (SAM) format and SAMtools, Bioinformatics (2009) 25(16) 2078-9

Love MI, Huber W and Anders S (2014). “Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2.” Genome Biology, 15, pp. 550. doi: 10.1186/s13059-014-0550-8. 


