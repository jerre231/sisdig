library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    Port (
        clk  : in  STD_LOGIC;
        bIn  : in  STD_LOGIC;
        bOut : out STD_LOGIC
    );
end debouncer;

architecture Behavioral of debouncer is
    constant CLK_FREQ_HZ   : integer := 50000000;
    constant DEBOUNCE_TIME : integer := 20; -- ms
    constant MAX_COUNT     : integer := CLK_FREQ_HZ / 1000 * DEBOUNCE_TIME;

    signal counter : integer range 0 to MAX_COUNT := 0;
    signal btn_reg : STD_LOGIC := '0';

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if bIn /= btn_reg then
                counter <= 0;
            elsif counter < MAX_COUNT then
                counter <= counter + 1;
            else
                btn_reg <= bIn;
            end if;
        end if;
    end process;

    bOut <= btn_reg;
end Behavioral;
