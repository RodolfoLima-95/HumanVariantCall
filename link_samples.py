#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 11 11:57:05 2024

@author: jrodolfo
"""
import json
import csv
import requests
import os
links=[]

def create_json():
    with open('igsr_samples.tsv', mode='r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file, delimiter='\t')
        for row in reader:
            sample = {
                    "ID":f"{row[0]}",
                    "url":f"ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/MXL/{row[0]}/alignment/{row[0]}.alt_bwamem_GRCh38DH.20150718.MXL.low_coverage.bam",
                    "BIOSAMPLE":f"{row[2]}",
                    "population":f"{row[3]}",
                    "sex":f"{row[1]}"}
            links.append(sample) 

    with open("sample.json","w") as file:
        json.dump(links, file)

def downcohort(jason: json):
    for sample in jason:
        response = requests.get(sample["url"], stream=True)
        if response.status_code == 200:
            print("Download feito com sucesso")
        else:
            print(f'Não foi possível baixar o alinhamento para a amostra {sample["ID"]}')
            continue
        
        output_dir = "data/"
        output_file = os.path.join(output_dir,f"{sample["ID"]}.bam")
        if not os.path.exists(output_dir):
            print("Você ainda não criou a pasta data/ com o foldcreate")
            
        with open(output_file, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

        print(f"Download concluído para {sample["ID"]}!")