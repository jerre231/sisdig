library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comp_arch is 
    port(
        A, B : in STD_LOGIC_VECTOR(3 downto 0); -- Entradas A e B

        EQ, LT, GT : out STD_LOGIC -- Saídas de comparação
    );

end comp_arch;

architecture Behavioral of comp_arch is
 
begin
    process(A, B)
    begin
        if A = B then
            EQ <= '1';
            LT <= '0';
            GT <= '0';
        elsif A < B then
            EQ <= '0';
            LT <= '1';
            GT <= '0';
        else
            EQ <= '0';
            LT <= '0';
            GT <= '1';
        end if;
    end process;

end Behavioral;