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

    signal counter : integer := 0;
    signal stable  : STD_LOGIC := '0';

    type state is (E0, E1)
    signal current_state : state := E0;

begin

    process(clock)
    begin
        -- if risingedge clock
        if rising_edge(stable) then
            case current_state is
                when E0 =>
                    if not button_in = stable then
                        counter = '0';
                        stable <= button_in;
                        current_state <= E1;
                    end if;
                when E1 =>
                    if counter < 30000000 then
                        counter = counter + 1;
                    else
                        current_state <= E0;
                    end if;
            end case;
        end if;
    end process;
end logic;
