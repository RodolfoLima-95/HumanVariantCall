# -*- coding: utf-8 -*-
"""
Editor Spyder

Este é um arquivo de script temporário.
"""

folders = ['data','results','scripts','output','tools' ]
import os
import argparse
import shutil

def create_directory(folder_name):
    # Verifica se o diretório já existe
    if not os.path.exists(folder_name):
        # Cria o diretório
        os.makedirs(folder_name)
        print(f'Pasta "{folder_name}" criada com sucesso!')
    else:
        print(f'Pasta "{folder_name}" já existe.')

    for i in folders:
        subfolder_path = os.path.join(folder_name, i)
        if not os.path.exists(subfolder_path):
            os.makedirs(subfolder_path)
            print(f'Subpasta "{i}" criada com sucesso dentro de "{folder_name}"!')
        else:
            print(f'Subpasta "{i}" já existe dentro de "{folder_name}".')



    def copiar_pasta():
        origem=str(os.getcwd())
        destino=f"{origem}/{folder_name}/reference/"
        origem="/home/jrodolfo/projects/genomes"
        destino=f"/home/jrodolfo/projects/genomes/{folder_name}/reference/" 
        # Verifica se o diretório de origem existe
        if not os.path.exists(origem):
            print(f"A pasta de origem '{origem}' não existe.")
            return

        # Verifica se o destino já existe
#        if os.path.exists(destino):
#            print(f"O destino '{destino}' já existe. Escolha outro destino ou remova a pasta existente.")
#            return

        try:
            # Copia a pasta de origem para o destino
            shutil.copytree(origem, destino)
            print(f"A pasta '{origem}' foi copiada com sucesso para '{destino}'.")
        except Exception as e:
            print(f"Erro ao copiar a pasta: {e}")

    if __name__ == "__main__":


        # Chama a função para copiar a pasta
        copiar_pasta()


if __name__ == "__main__":
    # Define o parser de argumentos
    parser = argparse.ArgumentParser(description="Cria uma pasta com o nome fornecido.")
    parser.add_argument("folder_name", type=str, help="Nome da pasta a ser criada.")

    # Obtém o argumento da linha de comando
    args = parser.parse_args()

    # Cria o diretório com o nome fornecido
    create_directory(args.folder_name)
