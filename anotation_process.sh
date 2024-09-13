#!/bin/bash

# Lista todos os arquivos na pasta atual
for file in *; do
  # Verifica se é um arquivo (e não um diretório)
  if [ -f "$file" ]; then
    # Usa basename para remover a extensão do arquivo
    filename=$(basename "$file" | sed 's/\.[^.]*$//')

    gatk VariantFiltration \
	-R reference/hg38.fa \
	-V results/${filename}_raw_indels.vcf \
	-O results/${filename}_filtered_indels.vcf \
	-filter-name "QD_filter" -filter "QD < 2.0" \
	-filter-name "FS_filter" -filter "FS > 200.0" \
	-filter-name "SOR_filter" -filter "SOR > 10.0" \
	-genotype-filter-expression "DP < 10" \
	-genotype-filter-name "DP_filter" \
	-genotype-filter-expression "GQ < 10" \
	-genotype-filter-name "GQ_filter"

    gatk SelectVariants \
	--exclude-filtered \
	-V results/${filename}_filtered_indels.vcf \
	-O results/${filename}_analysis-ready-indels.vcf

    cat results/${filename}_analysis-ready-snps.vcf|grep -v -E "DP_filter|GQ_filter" > results/${filename}_analysis-ready-snps-filteredGT.vcf
    cat results/${filename}_analysis-ready-indels.vcf|grep -v -E "DP_filter|GQ_filter" > results/${filename}_analysis-ready-indels-filteredGT.vcf

    gatk Funcotator \
    --variant results/${filename}_analysis-ready-snps-filteredGT.vcf \
    --reference reference/hg38.fa \
    --ref-version hg38 \
    --data-sources-path funcotator_dataSources.v1.8.hg38.20230908g \
    --output results/${filename}_analysis-ready-snps-filteredGT-functotated.vcf \
    --output-file-format VCF 
 
    gatk Funcotator \
        --variant results/${filename}_analysis-ready-indels-filteredGT.vcf \
        --reference reference/hg38.fa \
        --ref-version hg38 \
        --data-sources-path funcotator_dataSources.v1.8.hg38.20230908g \
        --output results/${filename}_analysis-ready-indels-filteredGT-functotated.vcf \
        --output-file-format VCF