library IEEE;
use STD_LOGIC_1164.ALL;

entity GT is
    port map(
        A, B : in STD_LOGIC;

        GT : out STD_LOGIC
    );

end GT;

architecture Behavioral of GT is

begin
    process(A, B) 
        begin
            if A > B then
                GT <= '1';

            else then
                GT <= '0';

            end if;

        end process;

end Behavioral;