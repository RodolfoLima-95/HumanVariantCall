#!/bin/bash

# Lista todos os arquivos na pasta atual
for file in *; do
  # Verifica se é um arquivo (e não um diretório)
  if [ -f "$file" ]; then
    # Usa basename para remover a extensão do arquivo
    filename=$(basename "$file" | sed 's/\.[^.]*$//')
    
    samtools sort -o output/${ERR050095}.align.sorted.bam output/${ERR050095}.align.sam

    gatk SortSam -I output/${filename}.align.sorted.bam -O output/${filename}.align.sorted.coord.bam -SO coordinate

    samtools index output/${filename}.align.sorted.coord.bam

    gatk MarkDuplicates -I output/${filename}.align.sorted.coord.bam -O output/${filename}.align.sorted.coord.dedup.bam -M output/ERR050095.align.sorted.coord.dedup.metric.txt

    gatk BaseRecalibrator \
        -I output/${ERR050095}.align.sorted.coord.dedup.bam \
        -R reference/hg38.fa \
        --known-sites data/Homo_sapiens_assembly38.dbsnp138.vcf \
        -O output/recal_data.table 

    gatk ApplyBQSR \
        -I output/${filename}.align.sorted.coord.dedup.bam \
        -R reference/hg38.fa \
        --bqsr-recal-file output/recal_data.table \
        -O output/${filename}.align.sorted.coord.dedup.bqsr.bam

    gatk HaplotypeCaller \
        -R reference/hg38.fa \
        -I output/${filename}.align.sorted.coord.dedup.bqsr.bam \ 
        -ERC GVCF \ 
        -L chr20 \
        -O results/${filename}_raw_variants.vcf
    
    bcftools view -v snps results/${filename}_raw_variants.vcf -o results/${filename}_raw_snps.vcf

    bcftools view -v indels results/${filename}_raw_variants.vcf -o results/${filename}_raw_indels.vcf

    gatk VariantFiltration \
	-R reference/hg38.fa \
	-V results/${filename}_raw_snps.vcf \
	-O results/${filename}_filtered_snps.vcf \
	-filter-name "QD_filter" -filter "QD < 2.0" \
	-filter-name "FS_filter" -filter "FS > 60.0" \
	-filter-name "MQ_filter" -filter "MQ < 40.0" \
	-filter-name "SOR_filter" -filter "SOR > 4.0" \
	-filter-name "MQRankSum_filter" -filter "MQRankSum < -12.5" \
	-filter-name "ReadPosRankSum_filter" -filter "ReadPosRankSum < -8.0" \
	-genotype-filter-expression "DP < 10" \
	-genotype-filter-name "DP_filter" \
	-genotype-filter-expression "GQ < 10" \
	-genotype-filter-name "GQ_filter"

    gatk SelectVariants \
	--exclude-filtered \
	-V results/${filename}_filtered_snps.vcf \
	-O results/${filename}_analysis-ready-snps.vcf

