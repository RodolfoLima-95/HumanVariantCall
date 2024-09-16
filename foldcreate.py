# -*- coding: utf-8 -*-
"""
Editor Spyder

Este é um arquivo de script temporário.
"""

import os
import argparse

def create_directory(folder_name):
    # Verifica se o diretório já existe
    if not os.path.exists(folder_name):
        # Cria o diretório
        os.makedirs(folder_name)
        print(f'Pasta "{folder_name}" criada com sucesso!')
    else:
        print(f'Pasta "{folder_name}" já existe.')

if __name__ == "__main__":
    # Define o parser de argumentos
    parser = argparse.ArgumentParser(description="Cria uma pasta com o nome fornecido.")
    parser.add_argument("folder_name", type=str, help="Nome da pasta a ser criada.")

    # Obtém o argumento da linha de comando
    args = parser.parse_args()

    # Cria o diretório com o nome fornecido
    create_directory(args.folder_name)
