library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_ula is
end tb_ula;

architecture behavioral of tb_ula is

    component ula is
        port(
            I : in STD_LOGIC_VECTOR(3 downto 0);
            button : in STD_LOGIC;
            clk : in STD_LOGIC;
          
            S : out STD_LOGIC_VECTOR(3 downto 0);
            F_Z, F_N, F_C, F_O : out STD_LOGIC
        );
    end component;

    signal I : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal button : STD_LOGIC := '0';
    signal clk : STD_LOGIC := '0';

    signal S : STD_LOGIC_VECTOR(3 downto 0);
    signal F_Z, F_N, F_C, F_O : STD_LOGIC;

    constant clk_period : time := 20 ns;

begin 

    -- Instancia a ULA
    uut: ula
        port map (
            I => I,
            button => button,
            clk => clk,
            S => S,
            F_Z => F_Z, F_N => F_N, F_C => F_C, F_O => F_O
        );

    -- Processo de clock
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Processo de estímulo
    stim: process
    begin
        assert false report "Iniciando simulação..." severity note;

        wait for 100 ns;

        button <= '1';
        wait for 5 ms;
        button <= '0';
        wait for 5 ms;

        -- Etapa 1: OP = 000 (ADD)
        I <= "0000";  -- OP = 000
        button <= '1';
        wait for 15 ms;
        button <= '0';
        wait for 5 ms;

        -- Etapa 2: A = 4
        I <= "0100";
        button <= '1';
        wait for 15 ms;
        button <= '0';
        wait for 5 ms;

        -- Etapa 3: B = 2
        I <= "0010";
        button <= '1';
        wait for 15 ms;
        button <= '0';
        wait for 5 ms;

        button <= '1';
        wait for 15 ms;
        button <= '0';
        wait for 5 ms;

        -- Etapa 4: resultado aparece, aguardar para observar
        wait for 10 ms;

        assert false report "Fim da simulação com sucesso." severity note;
        wait;
    end process;

end behavioral;
