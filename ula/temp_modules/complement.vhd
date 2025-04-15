library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity complement is
    port map(
        A : in STD_LOGIC_VECTOR(3 downto 0);  -- Número de entrada

        ret : out STD_LOGIC_VECTOR(3 downto 0);
        flag_zero : out STD_LOGIC;  -- Flag de zero
        flag_neg : out STD_LOGIC   -- Flag de negativo
    );

end complement;

architecture Behavioral of complement is

begin
    
    ret <= NOT A + '0001';

    flag_zero <= '1' when ret = "0000" else '0';
    
    flag_neg <= '1' when ret(3) = '1' else '0';

end Behavioral