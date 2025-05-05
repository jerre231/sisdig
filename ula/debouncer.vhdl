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
    
    constant MAX_COUNT     : integer := 30000000;

    signal counter : integer := 0;
    signal btn_reg : STD_LOGIC := '0';

    type state is (E0, E1);
    signal current_state : state := E0;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            case current_state is
                when E0 =>
                    if bIn /= btn_reg then
                        counter <= 0;
                        btn_reg <= bIn;
                        current_state <= E1;
                    end if;
                when E1 =>
                    if counter < MAX_COUNT then
                        counter <= counter + 1;
                    else
                        current_state <= E0;
                    end if;
            end case;

            bOut <= btn_reg;

        end if;
    
    end process;

end Behavioral;
