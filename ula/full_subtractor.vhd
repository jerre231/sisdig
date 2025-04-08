library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_subtractor is
    Port (
        A       : in  STD_LOGIC;  -- Minuendo
        B       : in  STD_LOGIC;  -- Subtraendo
        Bin     : in  STD_LOGIC;  -- Empréstimo de entrada

        Diff    : out STD_LOGIC;  -- Diferença
        Bout    : out STD_LOGIC   -- Empréstimo de saída
    );
end full_subtractor;

architecture Behavioral of full_subtractor is
begin
    process(A, B, Bin)
    begin
        Diff <= A xor B xor Bin;  
        
        Bout <= (not A and B) or ((not A or B) and Bin);  
    end process;
end Behavioral; 