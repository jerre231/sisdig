library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debouncer is
    port (
        clock      : in STD_LOGIC;
        button_in  : in STD_LOGIC;  -- Noisy button input
        button_out : out STD_LOGIC  -- Debounced button output
    );
end debouncer;

architecture logic of debouncer is

    constant clk_period      : time := 20 ns;    -- Clock period (50 MHz)
    constant debounce_time   : time := 10 ms;    -- Debounce time
    constant debounce_count  : integer := integer(debounce_time / clk_period);

    signal counter : integer := 0;
    signal stable  : STD_LOGIC := '0';

begin

    process(clock)
    begin
        if rising_edge(clock) then
            if button_in = '1' then
                if counter < debounce_count then
                    counter <= counter + 1;
                end if;
                if counter = debounce_count - 1 then
                    stable <= '1';
                end if;
            else
                counter <= 0;
                stable <= '0';
            end if;
        end if;
    end process;

    button_out <= stable;

end logic;
