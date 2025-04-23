library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debouncer is
-- Nenhuma porta, pois é um testbench
end tb_debouncer;

architecture behavior of tb_debouncer is

    -- Component declaration
    component debouncer is
        port (
            clock       : in STD_LOGIC;
            button_in   : in STD_LOGIC;
            button_out  : out STD_LOGIC
        );
    end component;

    -- Signals to connect to UUT (Unit Under Test)
    signal clock      : STD_LOGIC := '0';
    signal button_in  : STD_LOGIC := '0';
    signal button_out : STD_LOGIC;

    -- Clock period definitions
    constant clk_period : time := 20 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: debouncer
        port map (
            clock      => clock,
            button_in  => button_in,
            button_out => button_out
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clock <= '0';
            wait for clk_period / 2;
            clock <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        assert false report "Iniciando simulação..." severity note;

        -- Inicialização
        wait for 100 ns;

        -- Simular "ruído" do botão
        button_in <= '1';
        wait for 200 ns;
        button_in <= '0';
        wait for 100 ns;
        button_in <= '1';
        wait for 50 ns;
        button_in <= '0';
        wait for 50 ns;
        button_in <= '1';
        wait for 20 ms; -- manter pressionado mais que o debounce_time
        button_in <= '0';
        wait for 5 ms;

        -- Outra sequência ruidosa
        button_in <= '1';
        wait for 1 ms;
        button_in <= '0';
        wait for 1 ms;
        button_in <= '1';
        wait for 15 ms;
        button_in <= '0';

        wait;
    end process;

end behavior;
