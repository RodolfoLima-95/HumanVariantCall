#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 11 11:57:05 2024

@author: jrodolfo
"""
import json
ID=[]
import csv
links=[]

with open('igsr_samples.tsv', mode='r', newline='', encoding='utf-8') as file:
    reader = csv.reader(file, delimiter='\t')
    for row in reader:
        ID.append(row[0])

for i in ID:
    sample = {i:f"ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/MXL/{i}/alignment/{i}.alt_bwamem_GRCh38DH.20150718.MXL.low_coverage.cram"}
    links.append(sample) 

with open("sample.json","w") as file:
    json.dump(links, file)
