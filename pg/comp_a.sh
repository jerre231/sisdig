# Analisar os arquivos (compilação)
ghdl -a -fsynopsys adder.vhdl
ghdl -a -fsynopsys tb_adder.vhdl

# Elaborar (linkar o testbench)
ghdl -e -fsynopsys tb_adder

# Rodar a simulação (sem visualização ainda)
ghdl -r -fsynopsys tb_adder --vcd=waveform_adder.vcd