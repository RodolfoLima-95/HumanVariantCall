#!/bin/bash

DIR = 'data/'
for file in "$DIR"/*; do
  # Verifica se é um arquivo (e não um diretório)
  if [ -f "$file" ]; then
    # Usa basename para remover a extensão do arquivo
    filename=$(basename "$file" | sed 's/\.[^.]*$//')

    gatk VariantFiltration \
        -R reference/hg38.fa \
        -V results/{$filename}_raw_snps.vcf \
        -O results/{$filename}_filtered_snps.vcf \
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
        -V results/{$filename}_filtered_snps.vcf \
        -O results/{$filename}_analysis-ready-snps.vcf

    gatk VariantFiltration \
        -R reference/hg38.fa \
        -V results/{$filename}_raw_indels.vcf \
        -O results/{$filename}_filtered_indels.vcf \
        -filter-name "QD_filter" -filter "QD < 2.0" \
        -filter-name "FS_filter" -filter "FS > 200.0" \
        -filter-name "SOR_filter" -filter "SOR > 10.0" \
        -genotype-filter-expression "DP < 10" \
        -genotype-filter-name "DP_filter" \
        -genotype-filter-expression "GQ < 10" \
        -genotype-filter-name "GQ_filter"

    gatk SelectVariants \
        --exclude-filtered \
        -V results/{$filename}_filtered_indels.vcf \
        -O results/{$filename}_analysis-ready-indels.vcf

    cat results/{$filename}_analysis-ready-snps.vcf|grep -v -E "DP_filter|GQ_filter" > results/{$filename}_analysis-ready-snps-filteredGT.vcf
    cat results/{$filename}_analysis-ready-indels.vcf|grep -v -E "DP_filter|GQ_filter" > results/{$filename}_analysis-ready-indels-filteredGT.vcf

    gatk Funcotator \
        --variant results/{$filename}_analysis-ready-snps-filteredGT.vcf \
        --reference reference/hg38.fa \
        --ref-version hg38 \
        --data-sources-path funcotator_dataSources.v1.8.hg38.20230908g \
        --output results/{$filename}_analysis-ready-snps-filteredGT-functotated.vcf \
        --output-file-format VCF 
 
    gatk Funcotator \
        --variant results/{$filename}_analysis-ready-indels-filteredGT.vcf \
        --reference reference/hg38.fa \
        --ref-version hg38 \
        --data-sources-path funcotator_dataSources.v1.8.hg38.20230908g \
        --output results/{$filename}_analysis-ready-indels-filteredGT-functotated.vcf \
        --output-file-format VCF
    
    gatk VariantsToTable \
        -V results/{$filename}_analysis-ready-snps-filteredGT-functotated.vcf -F AC -F AN -F DP -F AF -F FUNCOTATION \
        -O results/{$filename}_output_notations_snps.table

    gatk VariantsToTable \
	    -V results/{$filename}_analysis-ready-indels-filteredGT-functotated.vcf -F AC -F AN -F DP -F AF -F FUNCOTATION \
	    -O results/{$filename}_output_notations_indels.table