library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debouncer_old is
    port (
        clock : in STD_LOGIC;
        button_in  : in STD_LOGIC;  -- Noisy button input
        button_out : out STD_LOGIC  -- Debounced button output
    );
end debouncer_old;

architecture logic of debouncer_old is
    constant clk_freq : INTEGER := 50000000; -- Clock frequency in Hz (50 MHz)
    constant debounce_time : INTEGER := 10; -- Debounce time in milliseconds
    constant debounce_count : INTEGER := (clk_freq / 1000) * debounce_time;

    signal counter : INTEGER := 0;          -- Counter for debounce timing
    signal FF1, FF2 : STD_LOGIC;            -- Flip-flops for synchronization
    signal button_stable : STD_LOGIC := '0'; -- Stable button signal
begin

    -- Synchronize the button input to the clock domain
    process(clock)
    begin
        if rising_edge(clock) then
            FF1 <= button_in;
            FF2 <= FF1;
        end if;
    end process;

    -- Debounce logic
    process(clock)
    begin
        if rising_edge(clock) then
            if FF2 /= button_stable then
                counter <= counter + 1;
                if counter >= debounce_count then
                    button_stable <= FF2;
                    counter <= 0;
                end if;
            else
                counter <= 0;
            end if;
        end if;
    end process;

    -- Output the stable button signal
    button_out <= button_stable;

end logic;