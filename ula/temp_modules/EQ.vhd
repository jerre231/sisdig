library IEEE;
use STD_LOGIC_1164.ALL;

entity EQ is
    port map(
        A, B : in STD_LOGIC;
        
        EQ : out STD_LOGIC
    );
    
end EQ;

architecture Behavioral of EQ is
begin
    process(A, B) 
        begin
            if A = B then
                EQ <= '1';
                
            else
                EQ <= '0';
                
            end if;
            
        end process;
        
end Behavioral;