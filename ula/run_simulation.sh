#!/bin/bash

# Define os arquivos VHDL e a unidade de teste
VHDL_SOURCES="debouncer.vhdl ula.vhdl tb_ula.vhdl"
EXEC="tb_ula"
WAVE="ula.ghw"

# Flags para o GHDL
GHDL_FLAGS="--std=08 -fsynopsys"

# Compila os arquivos VHDL
echo "Compilando os arquivos VHDL..."
ghdl -a $GHDL_FLAGS $VHDL_SOURCES

# Cria o executável
echo "Criando o executável..."
ghdl -e $GHDL_FLAGS $EXEC

# Executa a simulação
echo "Rodando a simulação..."
ghdl -r $GHDL_FLAGS $EXEC --wave=$WAVE

# Limpa arquivos temporários
echo "Limpando arquivos temporários..."
rm -f *.o

echo "Simulação concluída!"
