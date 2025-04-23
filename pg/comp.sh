# Analisar os arquivos (compilação)
ghdl -a -fsynopsys debouncer.vhdl
ghdl -a -fsynopsys tb_debouncer.vhdl

# Elaborar (linkar o testbench)
ghdl -e -fsynopsys tb_debouncer

# Rodar a simulação (sem visualização ainda)
ghdl -r -fsynopsys tb_debouncer --vcd=waveform.vcd