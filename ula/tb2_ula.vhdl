library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb2_ula is
end tb2_ula;

architecture sim of tb2_ula is

    -- Component declaration
    component ula
        port(
            I : in STD_LOGIC_VECTOR(3 downto 0);
            button : in STD_LOGIC;
            clk : in STD_LOGIC;
            S : out STD_LOGIC_VECTOR(3 downto 0);
            F_Z, F_N, F_C, F_O : out STD_LOGIC
        );
    end component;

    -- Signals to connect to UUT (Unit Under Test)
    signal I_tb : STD_LOGIC_VECTOR(3 downto 0);
    signal button_tb : STD_LOGIC := '0';
    signal clk_tb : STD_LOGIC := '0';
    signal S_tb : STD_LOGIC_VECTOR(3 downto 0);
    signal F_Z_tb, F_N_tb, F_C_tb, F_O_tb : STD_LOGIC;

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the UUT
    uut: ula
        port map (
            I => I_tb,
            button => button_tb,
            clk => clk_tb,
            S => S_tb,
            F_Z => F_Z_tb,
            F_N => F_N_tb,
            F_C => F_C_tb,
            F_O => F_O_tb
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
        procedure press_button is
        begin
            button_tb <= '1';
            wait for 20 ns;
            button_tb <= '0';
            wait for 50 ns;
        end procedure;

    begin
        wait for 100 ns; -- Inicialização

        -- OP = "000" (ADD)
        I_tb <= "0000";     -- OP = ADD
        press_button;

        I_tb <= "0010";    -- A = 2
        press_button;

        I_tb <= "0011";    -- B = 3
        press_button;

        wait for 100 ns;

        -- OP = "001" (SUB)
        I_tb <= "0001";     -- OP = SUB
        press_button;

        I_tb <= "0100";    -- A = 4
        press_button;

        I_tb <= "0001";    -- B = 1
        press_button;

        wait for 100 ns;

        -- OP = "100" (XOR)
        I_tb <= "0100";     -- OP = XOR
        press_button;

        I_tb <= "1100";    -- A = 12
        press_button;

        I_tb <= "1010";    -- B = 10
        press_button;

        wait for 100 ns;

        -- End simulation
        wait;
    end process;

end sim;
