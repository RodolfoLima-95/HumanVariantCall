#!/bin/bash

# Lista todos os arquivos na pasta atual
DIR = 'data/'
for file in "$DIR"/*; do
  # Verifica se é um arquivo (e não um diretório)
  if [ -f "$file" ]; then
    # Usa basename para remover a extensão do arquivo
    filename=$(basename "$file" | sed 's/\.[^.]*$//')
    
    samtools sort -o output/{$filename}.align.sorted.bam output/{$filename}.bam

    gatk SortSam -I output/{$filename}.align.sorted.bam -O output/{$filename}.align.sorted.coord.bam -SO coordinate

    samtools index output/{$filename}.align.sorted.coord.bam

    gatk MarkDuplicates -I output/{$filename}.align.sorted.coord.bam -O output/{$filename}.align.sorted.coord.dedup.bam -M output/ERR050095.align.sorted.coord.dedup.metric.txt

    gatk BaseRecalibrator \
        -I output/${ERR050095}.align.sorted.coord.dedup.bam \
        -R reference/hg38.fa \
        --known-sites data/Homo_sapiens_assembly38.dbsnp138.vcf \
        -O output/recal_data.table 

    gatk ApplyBQSR \
        -I output/{$filename}.align.sorted.coord.dedup.bam \
        -R reference/hg38.fa \
        --bqsr-recal-file output/recal_data.table \
        -O output/{$filename}.align.sorted.coord.dedup.bqsr.bam

    gatk HaplotypeCaller \
        -R reference/hg38.fa \
        -I output/{$filename}.align.sorted.coord.dedup.bqsr.bam \ 
        -ERC GVCF \ 
        -L chr20 \
        -O results/{$filename}_raw_variants.vcf
    
    bcftools view -v snps results/{$filename}_raw_variants.vcf -o results/{$filename}_raw_snps.vcf

    bcftools view -v indels results/{$filename}_raw_variants.vcf -o results/{$filename}_raw_indels.vcf

