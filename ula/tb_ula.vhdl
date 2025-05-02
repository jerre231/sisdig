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

    signal I_tb : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal button_tb : STD_LOGIC := '0';
    signal clk_tb : STD_LOGIC := '0';

    signal S_tb : STD_LOGIC_VECTOR(3 downto 0);
    signal F_Z, F_N, F_C, F_O : STD_LOGIC;

    constant clk_period : time := 20 ns;

begin

    -- Instancia a ULA
    uut: ula
        port map (
            I => I_tb,
            button => button_tb,
            clk => clk_tb,
            S => S_tb,
            F_Z => F_Z, F_N => F_N, F_C => F_C, F_O => F_O
        );

    -- Processo de clock
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Processo de est�mulo
    stim: process
    begin
        assert false report "Iniciando simula��o..." severity note;

        wait for 100 ns;

        button_tb <= '1';
        wait for 5 ms;
        button_tb <= '0';
        wait for 5 ms;

        -- Etapa 1: OP = 000 (ADD)
        I_tb <= "0010";  -- OP = 000
        button_tb <= '1';
        wait for 15 ms;
        button_tb <= '0';
        wait for 5 ms;

        -- Etapa 2: A = 4
        I_tb <= "0100";
        button_tb <= '1';
        wait for 15 ms;
        button_tb <= '0';
        wait for 5 ms;

        -- Etapa 3: B = 2
        I_tb <= "0110";
        button_tb <= '1';
        wait for 15 ms;
        button_tb <= '0';
        wait for 5 ms;

        -- Etapa 4: resultado aparece, aguardar para observar
        wait for 10 ms;

        assert false report "Fim da simula��o com sucesso." severity note;
        wait;
    end process;

end behavioral;
